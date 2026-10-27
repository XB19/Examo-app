-- Sur ecole.gouv.tg, le fichier « 2023/Calcul mental.pdf » contient en réalité le sujet de
-- CALCUL MENTAL de juin 2024 (en-tête « CEPD JUIN 2024 »), déjà présent dans le catalogue.
-- On le retire pour ne pas présenter aux élèves un sujet de 2024 comme étant celui de 2023.
DELETE FROM exam
WHERE level = 'CEPD' AND session_year = 2023 AND session_month = 'JUIN' AND subject_code = 'CALCUL_MENTAL';
