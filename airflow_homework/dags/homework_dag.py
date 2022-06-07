from airflow import DAG
from airflow.operators.python import PythonOperator
from airflow.operators.dummy import DummyOperator
from datetime import datetime

def print_hello():
	print('Hello, world!')

with DAG('homework_dag', 
		schedule_interval='@once', 
		start_date=datetime.now()) as homework_dag:

	start = DummyOperator(task_id='start', owner='admin')
	hello = PythonOperator(task_id='print_hello', 
						  python_callable=print_hello, owner='admin')
	end = DummyOperator(task_id='end', owner='admin')
