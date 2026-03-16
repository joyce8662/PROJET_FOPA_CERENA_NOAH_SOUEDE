
-- cette requête affiche les patients nées entre 1980 et 2000
SELECT nom, prenom, date_naissance
FROM PATIENT
WHERE date_naissance BETWEEN '1980-01-01' AND '2000-12-31';

-- cette requête affiche les rdv confirmés et terminés
SELECT id_rendez_vous, statut
FROM RENDEZ_VOUS
WHERE statut IN ('Confirmé','Terminé');

-- cette requête affiche les paiements dont le montant est entre 20 et 100€
SELECT id_paiement, montant
FROM PAIEMENT
WHERE montant BETWEEN 20 AND 100;

-- affiche les medecins dont la spécialité a l'id 1, 2 et 3, à savoir medecine générale, dermathologie et cardiologie	
SELECT id_medecin, id_specialite
FROM MEDECIN_SPECIALITE
WHERE id_specialite IN (1,2,3);

-- affiche la date et l'heure des rdv de 2026
SELECT id_rendez_vous, date_heure
FROM RENDEZ_VOUS
WHERE date_heure BETWEEN '2026-01-01' AND '2026-12-31';

-- affiche le nombre de rdv par medecin
SELECT id_medecin, COUNT(*) AS nombre_rdv
FROM RENDEZ_VOUS
GROUP BY id_medecin;

-- affiche le nombre de consultation par rdv
SELECT id_rendez_vous, COUNT(*) AS nb_consultations
FROM CONSULTATION
GROUP BY id_rendez_vous;

-- affiche la moyenne de tous les avis
SELECT AVG(note) AS moyenne_notes
FROM AVIS;

-- affiche le nombre de médecins avec au plus 2 rdv
SELECT id_medecin, COUNT(*) AS nb_rdv
FROM RENDEZ_VOUS
GROUP BY id_medecin
HAVING COUNT(*) > 2;

-- sert a afficher la somme de tout les paiement par statut
SELECT statut, SUM(montant) AS total
FROM PAIEMENT
GROUP BY statut;

-- affiche les rdv avec les patients (interface medecin)
SELECT r.id_rendez_vous, p.nom, p.prenom
FROM RENDEZ_VOUS r
JOIN PATIENT p
ON r.id_patient = p.id_patient;

-- affiche les rdv avec les medecins (interface patient)
SELECT r.id_rendez_vous, m.nom
FROM RENDEZ_VOUS r
JOIN MEDECIN m
ON r.id_medecin = m.id_medecin;

-- affiche les rdv avec patients et medecins (totalité des rdv)
SELECT p.nom AS patient, m.nom AS medecin, r.date_heure
FROM RENDEZ_VOUS r
JOIN PATIENT p
ON r.id_patient = p.id_patient
JOIN MEDECIN m
ON r.id_medecin = m.id_medecin;

-- affiche les médecins et leur spécialité
SELECT m.nom, s.nom_specialite
FROM MEDECIN m
JOIN MEDECIN_SPECIALITE ms
ON m.id_medecin = ms.id_medecin
JOIN SPECIALITE s
ON ms.id_specialite = s.id_specialite;

-- affcieh les médecins meme sans rdv 
SELECT m.nom, r.id_rendez_vous
FROM MEDECIN m
LEFT JOIN RENDEZ_VOUS r
ON m.id_medecin = r.id_medecin;

-- affiche les medecins avec au moins un rdv
SELECT nom, prenom
FROM MEDECIN
WHERE id_medecin IN (
    SELECT id_medecin
    FROM RENDEZ_VOUS
);

-- affiche les medecins sans rdv
SELECT nom, prenom
FROM MEDECIN
WHERE id_medecin NOT IN (
    SELECT id_medecin
    FROM RENDEZ_VOUS
);

-- patient avec au moins un rdv
SELECT nom, prenom
FROM PATIENT p
WHERE EXISTS (
    SELECT *
    FROM RENDEZ_VOUS r
    WHERE r.id_patient = p.id_patient
);

-- paiement superieurs a n'importe quel paiement inferieur a 50
SELECT montant
FROM PAIEMENT
WHERE montant > ANY (
    SELECT montant
    FROM PAIEMENT
    WHERE montant < 50
);

-- paiement superieurs à n'importe quel paiement inferieur a 20
SELECT montant
FROM PAIEMENT
WHERE montant > ALL (
    SELECT montant
    FROM PAIEMENT
    WHERE montant < 20
);
