-- Sur ecole.gouv.tg, « 2021/Dictée-Question.pdf » contient en réalité la dictée de mai-juin 2022
-- (en-tête « CEPD MAI-JUIN 2022 », dictée « L’arbre ») : on la range en 2022, qui n’en avait pas.
UPDATE exam SET session_year = 2022
WHERE level = 'CEPD' AND session_year = 2021 AND session_month = 'JUIN' AND subject_code = 'DICTEE_QUESTIONS';

-- « 2021/Dictée.pdf » est bien la dictée-questions de juin 2021 (« L’espoir ») : même matière que les autres années.
UPDATE exam SET subject_code = 'DICTEE_QUESTIONS', subject_name = 'Dictée et questions'
WHERE level = 'CEPD' AND session_year = 2021 AND session_month = 'JUIN' AND subject_code = 'DICTEE';
