-- 3_insertion.sql

INSERT INTO SPECIALITE (id_specialite, nom) VALUES
(1,'Médecine générale'),
(2,'Dermatologie'),
(3,'Cardiologie'),
(4,'Pédiatrie'),
(5,'Psychiatrie');

INSERT INTO ETABLISSEMENT (id_etablissement, nom, ville) VALUES
(1,'Clinique Saint Martin','Paris'),
(2,'Centre Médical République','Lyon'),
(3,'Hôpital Pasteur','Marseille');

INSERT INTO UTILISATEUR (id_utilisateur, nom, prenom, email, type) VALUES
(1,'Dupont','Jean','jean.dupont@telemed.fr','medecin'),
(2,'Moreau','Claire','claire.moreau@telemed.fr','medecin'),
(3,'Bernard','Lucas','lucas.bernard@telemed.fr','medecin'),
(4,'Petit','Sophie','sophie.petit@email.fr','patient'),
(5,'Durand','Marc','marc.durand@email.fr','patient'),
(6,'Leroy','Emma','emma.leroy@email.fr','patient');

INSERT INTO MEDECIN (id_medecin) VALUES
(1),
(2),
(3);

INSERT INTO PATIENT (id_patient) VALUES
(4),
(5),
(6);

INSERT INTO MEDECIN_SPECIALITE (id_medecin, id_specialite) VALUES
(1,1),
(2,2),
(3,3);

INSERT INTO MEDECIN_ETABLISSEMENT (id_medecin, id_etablissement) VALUES
(1,1),
(2,2),
(3,3);

INSERT INTO DISPONIBILITE (id_disponibilite, id_medecin, jour_semaine, heure_debut, heure_fin) VALUES
(1,1,1,'09:00:00','12:00:00'),
(2,1,3,'14:00:00','17:00:00'),
(3,2,2,'10:00:00','13:00:00'),
(4,2,4,'15:00:00','18:00:00'),
(5,3,5,'09:00:00','12:00:00'),
(6,3,6,'14:00:00','17:00:00');

INSERT INTO RENDEZ_VOUS (id_rendez_vous, id_patient, id_medecin, date_heure, statut) VALUES
(1,4,1,'2026-04-06 09:30:00','Terminé'),
(2,5,2,'2026-04-07 10:30:00','Terminé'),
(3,6,3,'2026-04-10 09:30:00','Confirmé'),
(4,4,2,'2026-04-09 15:30:00','A venir');

INSERT INTO CONSULTATION (id_consultation, id_rendez_vous, compte_rendu) VALUES
(1,1,'Consultation pour symptômes grippaux, traitement prescrit.'),
(2,2,'Diagnostic dermatologique pour irritation cutanée.'),
(3,3,'Suivi cardiologique annuel.'),
(4,4,'Consultation dermatologique programmée.');

INSERT INTO AVIS (id_avis, id_consultation, note, commentaire) VALUES
(1,1,5,'Médecin très professionnel et à l’écoute'),
(2,2,4,'Consultation claire et efficace');

INSERT INTO PAIEMENT (id_paiement, mode_paiement, statut, montant) VALUES
(1,'CB','Validé',30.00),
(2,'Carte Vitale','Remboursé',50.00),
(3,'Mutuelle','En attente',70.00),
(4,'CB','En attente',45.00);

INSERT INTO CONSULTATION_PAIEMENT (id_consultation, id_paiement) VALUES
(1,1),
(2,2),
(3,3),
(4,4);
