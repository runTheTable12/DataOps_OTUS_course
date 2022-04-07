import time
from flask import Flask, render_template, flash, redirect, request, url_for
from flask_sqlalchemy import SQLAlchemy


DBUSER = 'anatolii'
DBPASS = 'anatolii'
DBHOST = 'db'
DBPORT = '5432'
DBNAME = 'otus_homework'


app = Flask(__name__)
app.config['SQLALCHEMY_DATABASE_URI'] = \
    'postgresql+psycopg2://{user}:{passwd}@{host}:{port}/{db}'.format(
        user=DBUSER,
        passwd=DBPASS,
        host=DBHOST,
        port=DBPORT,
        db=DBNAME)
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
app.secret_key = 'anatolii'


db = SQLAlchemy(app)


class Courses(db.Model):
    id = db.Column('course_id', db.Integer, primary_key=True)
    name = db.Column(db.String(100))
    description = db.Column(db.Text())

    def __init__(self, name, description):
        self.name = name
        self.description = description


def database_initialization_sequence():
    db.create_all()
    test_rec = Courses(
            'DataOps',
            'This is a nice course where you can learn docker, ansible and terraform')

    db.session.add(test_rec)
    db.session.rollback()
    db.session.commit()


@app.route('/', methods=['GET', 'POST'])
def home():
    if request.method == 'POST':
        if not request.form['name'] or not request.form['description']:
            flash('Please enter all the fields', 'error')
        else:
            course = Courses(
                    request.form['name'],
                    request.form['description'])

            db.session.add(course)
            db.session.commit()
            flash('Record was succesfully added')
            return redirect(url_for('home'))
    return render_template('show_all.html', courses=Courses.query.all())


if __name__ == '__main__':
    dbstatus = False
    while dbstatus == False:
        try:
            db.create_all()
        except:
            time.sleep(2)
        else:
            dbstatus = True
    database_initialization_sequence()
    app.run(debug=True, host='0.0.0.0')