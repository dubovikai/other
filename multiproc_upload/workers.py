import os
import pandas as pd
import cx_Oracle
import time
import traceback
import queue

def do_request(que_mess, que_for_proc, que_done, sql_query):
	proc = os.getpid()
	
	def set_comment(txt):
		que_mess.put(str(proc)+': '+time.strftime("%H:%M:%S")+': '+txt)
	
	dsn_tns = cx_Oracle.makedsn(host='***', port=***, service_name='***')
	conn_balu_rez = cx_Oracle.connect(user='***', password='***', dsn=dsn_tns, encoding='UTF-8')
	set_comment('Подключился к ***...')
	
	#Получение списка счетов клиента по его ИД
	def get_client_activity(cl_id, conn = conn_balu_rez, sql_query = sql_query):
		
		if conn is None:
			set_comment('Соединение с БД не установлено')
			return None

		v_ret = pd.read_sql(sql=sql_query, con=conn, params = {'cl_id':cl_id})

		return v_ret
	
	try:
		#Пока не пуста очередь для обработки
		while not que_for_proc.empty():
			cl_id = None
			cl_id = que_for_proc.get()
			
			if cl_id == 'PLEASE_DIE':
				break
			#Схватили...
			if not cl_id is None:
				#Положим результат в очередь результатов
				res = get_client_activity(int(cl_id))
				que_done.put(res)
		
	except Exception as err:
		set_comment('Ошибка id='+str(cl_id)+': '+str(err)+': \n'+traceback.format_exc())
	finally:
		conn_balu_rez.close()
		set_comment('Соединение с *** закрыто...')