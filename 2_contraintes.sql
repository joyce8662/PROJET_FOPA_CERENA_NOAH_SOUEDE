-- Basé sur les règles de gestion (RG01 à RG28)
-- =====================================================

-- =====================================================
-- RG02 : Format email valide
-- =====================================================
ALTER TABLE UTILISATEUR
ADD CONSTRAINT chk_email_format 
CHECK (email LIKE '%_@__%.__%' AND email NOT LIKE '@%' AND email NOT LIKE '%@%@%');

-- =====================================================
-- RG01/RG05 : Type utilisateur valide (patient/medecin)
-- =====================================================
ALTER TABLE UTILISATEUR
ADD CONSTRAINT chk_type_utilisateur
CHECK (type IN ('patient', 'medecin'));

-- =====================================================
-- RG06/RG07 : Jour semaine valide (1-7) et heures cohérentes
-- =====================================================
ALTER TABLE DISPONIBILITE
ADD CONSTRAINT chk_jour_semaine 
CHECK (jour_semaine BETWEEN 1 AND 7),
ADD CONSTRAINT chk_heures_dispo 
CHECK (heure_fin > heure_debut);

-- =====================================================
-- RG09 : Statut rendez-vous valide
-- =====================================================
ALTER TABLE RENDEZ_VOUS
ADD CONSTRAINT chk_statut_rdv 
CHECK (statut IN ('A venir', 'Confirmé', 'Terminé', 'Annulé patient', 'Annulé médecin'));

-- =====================================================
-- RG13 : Note avis entre 1 et 5
-- =====================================================
ALTER TABLE AVIS
ADD CONSTRAINT chk_note_avis 
CHECK (note BETWEEN 1 AND 5);

-- =====================================================
-- RG15 : Montant positif
-- =====================================================
ALTER TABLE PAIEMENT
ADD CONSTRAINT chk_montant_positif 
CHECK (montant >= 0);

-- =====================================================
-- RG15 : Mode paiement valide
-- =====================================================
ALTER TABLE PAIEMENT
ADD CONSTRAINT chk_mode_paiement 
CHECK (mode_paiement IN ('CB', 'Carte Vitale', 'Mutuelle'));

-- =====================================================
-- RG15 : Statut paiement valide
-- =====================================================
ALTER TABLE PAIEMENT
ADD CONSTRAINT chk_statut_paiement 
CHECK (statut IN ('En attente', 'Validé', 'Remboursé'));

-- =====================================================
-- RG15 : Montant partiel positif
-- =====================================================
ALTER TABLE CONSULTATION_PAIEMENT
ADD CONSTRAINT chk_montant_partiel 
CHECK (montant_partiel >= 0);

-- =====================================================
-- RG05 : Patient mineur doit avoir un tuteur (TRIGGER)
-- =====================================================
DELIMITER //
CREATE TRIGGER check_age_patient
BEFORE INSERT ON PATIENT
FOR EACH ROW
BEGIN
    DECLARE age INT;
    SET age = TIMESTAMPDIFF(YEAR, NEW.date_naissance, CURDATE());
    
    IF age < 18 AND NEW.id_tuteur IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'RG05: Un patient mineur doit avoir un tuteur';
    END IF;
    
    IF age >= 18 AND NEW.id_tuteur IS NOT NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RG05: Un patient majeur ne peut pas avoir de tuteur';
    END IF;
END//

-- =====================================================
-- RG08/RG12 : Rendez-vous必须在disponibilité du médecin (TRIGGER)
-- =====================================================
CREATE TRIGGER check_rendez_vous_disponibilite
BEFORE INSERT ON RENDEZ_VOUS
FOR EACH ROW
BEGIN
    DECLARE jour_semaine_rdv INT;
    DECLARE heure_rdv TIME;
    DECLARE dispo_count INT;
    
    -- Convertir DAYOFWEEK (1=Dimanche,2=Lundi...7=Samedi) en notre format (1=Lundi...7=Dimanche)
    SET jour_semaine_rdv = DAYOFWEEK(NEW.date_heure);
    SET jour_semaine_rdv = CASE 
        WHEN jour_semaine_rdv = 1 THEN 7  -- Dimanche
        ELSE jour_semaine_rdv - 1         -- Lundi à Samedi
    END;
    
    SET heure_rdv = CAST(NEW.date_heure AS TIME);
    
    SELECT COUNT(*) INTO dispo_count
    FROM DISPONIBILITE
    WHERE id_medecin = NEW.id_medecin
      AND jour_semaine = jour_semaine_rdv
      AND heure_debut <= heure_rdv
      AND heure_fin >= ADDTIME(heure_rdv, '00:30:00');
    
    IF dispo_count = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RG08/RG12: Le médecin n''est pas disponible à cette date et heure';
    END IF;
END//

-- =====================================================
-- RG10 : Une consultation ne peut avoir un avis que si elle est terminée (TRIGGER)
-- =====================================================
CREATE TRIGGER check_avis_consultation_terminee
BEFORE INSERT ON AVIS
FOR EACH ROW
BEGIN
    DECLARE consultation_statut VARCHAR(20);
    
    SELECT r.statut INTO consultation_statut
    FROM RENDEZ_VOUS r
    JOIN CONSULTATION c ON r.id_rendez_vous = c.id_rendez_vous
    WHERE c.id_consultation = NEW.id_consultation;
    
    IF consultation_statut != 'Terminé' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RG10: Un avis ne peut être donné que pour une consultation terminée';
    END IF;
END//

-- =====================================================
-- RG06 : Pas de chevauchement des disponibilités d'un médecin (TRIGGER)
-- =====================================================
CREATE TRIGGER check_disponibilite_chevauchante
BEFORE INSERT ON DISPONIBILITE
FOR EACH ROW
BEGIN
    DECLARE overlap_count INT;
    
    SELECT COUNT(*) INTO overlap_count
    FROM DISPONIBILITE
    WHERE id_medecin = NEW.id_medecin
      AND jour_semaine = NEW.jour_semaine
      AND (
          (NEW.heure_debut BETWEEN heure_debut AND heure_fin)
          OR (NEW.heure_fin BETWEEN heure_debut AND heure_fin)
          OR (heure_debut BETWEEN NEW.heure_debut AND NEW.heure_fin)
      );
    
    IF overlap_count > 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RG06: Cette disponibilité chevauche une disponibilité existante';
    END IF;
END//

-- =====================================================
-- RG15 : La somme des montants partiels doit correspondre au montant total (TRIGGER)
-- =====================================================
CREATE TRIGGER check_montant_total_paiement
AFTER INSERT ON CONSULTATION_PAIEMENT
FOR EACH ROW
BEGIN
    DECLARE total_partiel DECIMAL(10,2);
    DECLARE montant_total DECIMAL(10,2);
    DECLARE diff DECIMAL(10,2);
    
    -- Calculer la somme des montants partiels pour ce paiement
    SELECT SUM(montant_partiel), COUNT(*) INTO total_partiel, @count
    FROM CONSULTATION_PAIEMENT
    WHERE id_paiement = NEW.id_paiement;
    
    -- Récupérer le montant total du paiement
    SELECT montant INTO montant_total
    FROM PAIEMENT
    WHERE id_paiement = NEW.id_paiement;
    
    -- Vérifier si la somme des partiels dépasse le total
    IF total_partiel > montant_total + 0.01 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'RG15: La somme des montants partiels dépasse le montant total du paiement';
    END IF;
END//

