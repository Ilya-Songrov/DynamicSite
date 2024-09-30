## DynamicSite

### How to init Django?

1. **Install Django (venv)**
```
ROOT_DIR=~/DeveloperRoot/AllProjects/Ilya_Songrov/CryptoBand/DynamicSite
mkdir -p $ROOT_DIR
cd $ROOT_DIR
python3 --version # Python 3.10.12
python3.10 -m venv ./venv
source venv/bin/activate
pip3 install django
pip3 install psycopg2
pip3 install djangorestframework
pip3 install djangorestframework-jwt
pip3 install djangorestframework-simplejwt
pip3 install django-pgtrigger
pip3 install django-bootstrap-v5
pip3 install django-vite
pip3 install gunicorn
pip3.10 freeze > requirements.txt
deactivate
```

2. **Create project,applications**
```
cd $ROOT_DIR/
django-admin startproject DynamicSite $ROOT_DIR/
python3 manage.py startapp accounts
python3 manage.py startapp core
python3 manage.py makemigrations
python3 manage.py migrate
python3 manage.py runserver
```

3. **Create user**
```
python3 manage.py createsuperuser
```


4. **Run via gunicorn**
```
gunicorn --workers 3 --timeout 120 DynamicSite.wsgi:application
```