update settings
set value = 0
where name = 'self_registration';

update settings
set value = 0
where name = 'autofetch_changesets';

update users
set hashed_password = 'f927a118ab8ee9aeaf3ff23d4d250c60863141eb'
where type = 'User'
and admin = 0;

COMMIT;

