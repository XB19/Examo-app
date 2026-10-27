-- Sur ecole.gouv.tg, « 2020/problème dAout.pdf » contient en réalité le PROBLEME de juin 2021
-- (en-tête « CEPD JUIN 2021 », jardin rectangulaire) : on le range en 2021, qui n'en avait pas.
UPDATE exam SET session_year = 2021, session_month = 'JUIN'
WHERE level = 'CEPD' AND session_year = 2020 AND session_month = 'AOUT' AND subject_code = 'PROBLEME';

-- Tous les autres sujets du dossier 2020 portent l'en-tête « CEPD - AOÛT 2020 » :
-- la session 2020 a eu lieu en août (report lié au Covid-19).
UPDATE exam SET session_month = 'AOUT'
WHERE level = 'CEPD' AND session_year = 2020;
