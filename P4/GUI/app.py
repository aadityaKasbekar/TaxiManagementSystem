from sqlalchemy.engine import URL
import os
from flask import Flask, render_template, request, url_for, redirect
from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import create_engine
from sqlalchemy.sql import func
from sqlalchemy import text

url_object = URL.create(
    "mssql+pymssql",
    username="sa",
    password="12345OHdf%e",  # plain (unescaped) text
    host="localhost",
    port="1433",
    database="TaxiManagementSystem",
)

engine = create_engine(url_object)

connection = engine.connect()
# def get_employees():


app = Flask(__name__)


@app.route("/")  # For default route
def main():
    result = connection.execute(text("SELECT name FROM sys.tables"))
    option_list = []
    for row in result:
        option_list.append(str(row).strip("()").replace("'", "").rstrip(","))
    return render_template("base.html", option_list=option_list)


@app.route('/data', methods=['GET', 'POST'])
def show_service():
    mssqltips = []
    table = request.form.get('comp_select')
    if table == 'User':
        table = '[User]'
    result = connection.execute(text(f"SELECT * from {table}"))
    for row in result:
        mssqltips.append(
            row
        )
    return render_template('Customer.html', mssqltips=mssqltips, keys=result.keys())


if (__name__ == "__main__"):
    app.run()
