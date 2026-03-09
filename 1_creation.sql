CREATE DATABASE TELEMEDECINE;

USE TELEMEDECINE;
-- =====================================================
-- Table UTILISATEUR
-- =====================================================
CREATE TABLE UTILISATEUR (
    id_utilisateur INT PRIMARY KEY AUTO_INCREMENT,
    email VARCHAR(100) UNIQUE NOT NULL,
    mot_de_passe VARCHAR(255) NOT NULL,
    type VARCHAR(10) NOT NULL,
    date_inscription DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_derniere_connexion DATETIME,
    adresse_ip_derniere_connexion VARCHAR(45)
);

-- =====================================================
-- Table PATIENT
-- =====================================================
CREATE TABLE PATIENT (
    id_patient INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    date_naissance DATE NOT NULL,
    numero_securite_sociale VARCHAR(15) UNIQUE,
    id_tuteur INT,
    FOREIGN KEY (id_patient) REFERENCES UTILISATEUR(id_utilisateur) ON DELETE CASCADE,
    FOREIGN KEY (id_tuteur) REFERENCES PATIENT(id_patient) ON DELETE SET NULL
);

-- =====================================================
-- Table MEDECIN
-- =====================================================
CREATE TABLE MEDECIN (
    id_medecin INT PRIMARY KEY,
    nom VARCHAR(50) NOT NULL,
    prenom VARCHAR(50) NOT NULL,
    numero_rpps VARCHAR(11) UNIQUE NOT NULL,
    biographie TEXT,
    photo_url VARCHAR(255),
    FOREIGN KEY (id_medecin) REFERENCES UTILISATEUR(id_utilisateur) ON DELETE CASCADE
);

-- =====================================================
-- Table SPECIALITE
-- =====================================================
CREATE TABLE SPECIALITE (
    id_specialite INT PRIMARY KEY AUTO_INCREMENT,
    nom_specialite VARCHAR(50) UNIQUE NOT NULL
);

-- =====================================================
-- Table MEDECIN_SPECIALITE (Association many-to-many)
-- =====================================================
CREATE TABLE MEDECIN_SPECIALITE (
    id_medecin INT,
    id_specialite INT,
    PRIMARY KEY (id_medecin, id_specialite),
    FOREIGN KEY (id_medecin) REFERENCES MEDECIN(id_medecin) ON DELETE CASCADE,
    FOREIGN KEY (id_specialite) REFERENCES SPECIALITE(id_specialite) ON DELETE CASCADE
);

-- =====================================================
-- Table ETABLISSEMENT
-- =====================================================
CREATE TABLE ETABLISSEMENT (
    id_etablissement INT PRIMARY KEY AUTO_INCREMENT,
    nom_etablissement VARCHAR(100) NOT NULL,
    adresse TEXT NOT NULL
);

-- =====================================================
-- Table MEDECIN_ETABLISSEMENT (Association many-to-many)
-- =====================================================
CREATE TABLE MEDECIN_ETABLISSEMENT (
    id_medecin INT,
    id_etablissement INT,
    PRIMARY KEY (id_medecin, id_etablissement),
    FOREIGN KEY (id_medecin) REFERENCES MEDECIN(id_medecin) ON DELETE CASCADE,
    FOREIGN KEY (id_etablissement) REFERENCES ETABLISSEMENT(id_etablissement) ON DELETE CASCADE
);

-- =====================================================
-- Table DISPONIBILITE
-- =====================================================
CREATE TABLE DISPONIBILITE (
    id_disponibilite INT PRIMARY KEY AUTO_INCREMENT,
    jour_semaine INT NOT NULL,
    heure_debut TIME NOT NULL,
    heure_fin TIME NOT NULL,
    est_recurrent BOOLEAN DEFAULT TRUE,
    id_medecin INT NOT NULL,
    FOREIGN KEY (id_medecin) REFERENCES MEDECIN(id_medecin) ON DELETE CASCADE
);

-- =====================================================
-- Table RENDEZ_VOUS
-- =====================================================
CREATE TABLE RENDEZ_VOUS (
    id_rendez_vous INT PRIMARY KEY AUTO_INCREMENT,
    motif TEXT,
    date_heure DATETIME NOT NULL,
    statut VARCHAR(20) NOT NULL DEFAULT 'A venir',
    id_patient INT NOT NULL,
    id_medecin INT NOT NULL,
    FOREIGN KEY (id_patient) REFERENCES PATIENT(id_patient) ON DELETE RESTRICT,
    FOREIGN KEY (id_medecin) REFERENCES MEDECIN(id_medecin) ON DELETE RESTRICT
);

-- =====================================================
-- Table CONSULTATION
-- =====================================================
CREATE TABLE CONSULTATION (
    id_consultation INT PRIMARY KEY AUTO_INCREMENT,
    compte_rendu_url VARCHAR(255),
    ordonnance_url VARCHAR(255),
    heure_debut_reelle TIME,
    heure_fin_reelle TIME,
    id_rendez_vous INT UNIQUE NOT NULL,
    FOREIGN KEY (id_rendez_vous) REFERENCES RENDEZ_VOUS(id_rendez_vous) ON DELETE CASCADE
);

-- =====================================================
-- Table AVIS
-- =====================================================
CREATE TABLE AVIS (
    id_avis INT PRIMARY KEY AUTO_INCREMENT,
    note INT NOT NULL,
    commentaire TEXT,
    date_avis DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    id_consultation INT UNIQUE NOT NULL,
    FOREIGN KEY (id_consultation) REFERENCES CONSULTATION(id_consultation) ON DELETE CASCADE
);

-- =====================================================
-- Table PAIEMENT
-- =====================================================
CREATE TABLE PAIEMENT (
    id_paiement INT PRIMARY KEY AUTO_INCREMENT,
    montant DECIMAL(10,2) NOT NULL,
    mode_paiement VARCHAR(15) NOT NULL,
    statut VARCHAR(15) NOT NULL DEFAULT 'En attente',
    date_paiement DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    facture_url VARCHAR(255)
);

-- =====================================================
-- Table CONSULTATION_PAIEMENT (Association many-to-many)
-- =====================================================
CREATE TABLE CONSULTATION_PAIEMENT (
    id_consultation INT,
    id_paiement INT,
    montant_partiel DECIMAL(10,2),
    PRIMARY KEY (id_consultation, id_paiement),
    FOREIGN KEY (id_consultation) REFERENCES CONSULTATION(id_consultation) ON DELETE RESTRICT,
    FOREIGN KEY (id_paiement) REFERENCES PAIEMENT(id_paiement) ON DELETE RESTRICT
);