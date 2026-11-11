# MountClimb — Database (MySQL)

Taruh file script SQL (mis. `mountclimb.sql`) di folder ini.

Import lewat phpMyAdmin, atau:
```
mysql -u root -p -e "CREATE DATABASE mountclimb"
mysql -u root -p mountclimb < mountclimb.sql
```
Lalu samakan nama database di `.env` backend (`DB_DATABASE=mountclimb`).
