# Steps to get the UI running

# Ensure ```python3``` is installed.

# Create new virtual environment with the following command.
```virtualenv venv```

# Activate the virtual environment with the following command.
```source ./venv/bin/activate```

# Install the dependencies.
```pip3 install -r requirements.txt```

# To run the app. Run the following command.
```python3 app.py```


# PS. Please ensure that username and password for the database are entered in the app.py file. Line number 9

```python
url_object = URL.create(
    "mssql+pymssql",
    username="username",
    password="password",  # plain (unescaped) text
    host="localhost",
    port="1433",
    database="TaxiManagementSystem",
)
```
# Please note username and password refers to the username and password on your local systems.