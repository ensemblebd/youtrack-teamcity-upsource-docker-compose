CREATE USER jetbrains with encrypted password 'mypass';
CREATE DATABASE teamcity;
GRANT ALL PRIVILEGES ON DATABASE teamcity TO jetbrains;
