SELECT

--ID клиента
cl.id cl_id

--ИНН клиента
,cl.c_inn inn

--Номер счета
,acc.c_main_v_id acc_num

--статус счета
,st_acc.c_name acc_st

--дата открытия счета
,acc_parent.c_date_op acc_date_open

--дата закрытия счета
,acc_parent.c_date_close acc_date_close

--сумма дебета за последние 3 месяца
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date > add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_sum_3m

--количество платежей дебет за последние 3 месяца
,(select count(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_count_3m

--минимальная сумма платежей дебет за последние 3 месяца
,(select min(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_min_3m

--максимальная сумма платежей дебет за последние 3 месяца
,(select max(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_max_3m

--количество дней без дебет за последние 3 месяца
,(select (nvl(acc_parent.c_date_close,sysdate) - add_months(nvl(acc_parent.c_date_close,sysdate),-3)) - count(distinct(trunc(rec.c_date)))
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_empty_days_3m

--количество платежей дебет за все время
,(select count(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1') dt_count_all

--сумма кредита за последние 3 месяца
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_sum_3m

--количество платежей кредит за последние 3 месяца
,(select count(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_count_3m

--минимальная сумма платежей кредита за последние 3 месяца
,(select min(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_min_3m

--максимальная сумма платежей кредит за последние 3 месяца
,(select max(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_max_3m

--количество дней без кредита за последние 3 месяца
,(select (nvl(acc_parent.c_date_close,sysdate) - add_months(nvl(acc_parent.c_date_close,sysdate),-3)) - count(distinct(trunc(rec.c_date)))
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_empty_days_3m

--количество платежей кредит за все время
,(select count(*)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '0') kt_count_all

--среднее количество платежей за 2 недели
,(select trunc(avg(week.pay_count),3)
	from (select trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7) week_cnt, count(rec.c_summa_nat) pay_count
			from z#records rec
			where rec.collection_id = acc.c_arc_move
				and rec.c_date >= trunc(nvl(acc_parent.c_date_close,sysdate)) - 14
				and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate))
				and rec.c_dt = '1'
			group by trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7)) week) avg_dt_weekly_2

--среднее количество платежей за 14 недель
,(select trunc(avg(week.pay_count),3)
	from (select trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7) week_cnt, count(rec.c_summa_nat) pay_count
			from z#records rec
			where rec.collection_id = acc.c_arc_move
				and rec.c_date >= trunc(nvl(acc_parent.c_date_close,sysdate)) - 714
				and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate))
				and rec.c_dt = '1'
			group by trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7)) week) avg_dt_weekly_14

--Остаток месяца 0
,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
							and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),0),'mm'))) month_saldo_0

--Приход месяц 0
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-1),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),0),'mm')) month_sum_0

--Остаток месяца 1
,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
		where rec.collection_id = acc.c_arc_move
			and rownum = 1
			and rec.c_date = (select max(rec_month.c_date)
								from z#records rec_month
								where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-1),'mm'))) month_saldo_1

--Приход месяц 1
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-2),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-1),'mm')) month_sum_1

--Остаток месяца 2
,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-2),'mm'))) month_saldo_2

--Приход месяц 2
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-3),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-2),'mm')) month_sum_2

--Остаток месяца 3
,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-3),'mm'))) month_saldo_3

--Приход месяц 3
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-4),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-3),'mm')) month_sum_3

--Остаток месяца 4
,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-4),'mm'))) month_saldo_4

--Приход месяц 4
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-5),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-4),'mm')) month_sum_4

--Остаток месяца 5
,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-5),'mm'))) month_saldo_5

--Приход месяц 5
,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-6),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-5),'mm')) month_sum_5

--Пауза между открытием счета и первым платежом, суток
,(select trunc(min(rec.c_date)- acc_parent.c_date_op,3)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and upper(doc.c_nazn) not like '%КОМИС%') pay_delay

--Количество отклоненных документов по счету
,(select count(*)
	from z#records rec
		,z#document doc
		,z#history_states hist
	where rec.collection_id = acc.c_arc_move
		and rec.c_doc = doc.id
		and hist.collection_id = doc.c_history_state
		and hist.c_state = 'SKB_CHECK_UFE'
		and hist.c_add_info = 'REFUSE'
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)) decl_count

--количество запросов документов
,(select count(*)
	from z#fm fm
		,z#fm_client cl_fm
		,z#fm_params pars
		,z#cm_checkpoint chkp
	where fm.c_client_fm = cl_fm.id
		and cl_fm.c_client = cl.id
		and pars.collection_id = fm.c_params
		and pars.c_code = 'RQ_INFO'
		and pars.c_value = 'PAYMENT_REQUEST'
		and to_number(chkp.c_obj_ref) = fm.id
		and chkp.c_date_create > add_months(nvl(acc_parent.c_date_close,sysdate),-3)) request_count_docs

--количество запросов документов (по количеству заявок)
,(select count(*)
	from z#fm fm
		,z#fm_client cl_fm
		,z#fm_params pars
		,z#cm_checkpoint chkp
	where fm.c_client_fm = cl_fm.id
		and cl_fm.c_client = cl.id
		and pars.collection_id = fm.c_params
		and fm.c_business = 44956607143 --::[FM_BUSINESS](CODE = 'SKB_PODFT') 	
		and to_number(chkp.c_obj_ref) = fm.id
		and chkp.c_date_create > add_months(nvl(acc_parent.c_date_close,sysdate),-3)) request_count_all

--Количество проведенных платежей с признаком бюджетного платежа
,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_budget_payment = '1') cnt_budget_paym_all 

--Количество проведенных платежей с признаком бюджетного платежа
,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_budget_payment = '1') avg_sum_budget_paym_all 

--Количество проведенных платежей с признаком бюджетного платежа за последние 6 закрытых месяцев
,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_budget_payment = '1') cnt_budget_paym_6m 

--Средняя сумма проведенных платежей с признаком бюджетного платежа за последние 6 закрытых месяцев
,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_budget_payment = '1') avg_sum_budget_paym_6m 

--Количество проведенных платежей с признаком бюджетного платежа (по допреквизиту бюджетного платежа)
,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_bud_reqs#kbk_str like '182%') cnt_kbk182_all

--Количество проведенных платежей с признаком бюджетного платежа (по допреквизиту бюджетного платежа)
,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_bud_reqs#kbk_str like '182%') avg_sum_kbk182_all

--Количество проведенных платежей с признаком бюджетного платежа (по допреквизиту бюджетного платежа) за последние 6 закрытых месяцев
,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_bud_reqs#kbk_str like '182%') cnt_kbk182_6m

--Средняя сумма проведенных платежей с признаком бюджетного платежа (по допреквизиту бюджетного платежа) за последние 6 закрытых месяцев
,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_bud_reqs#kbk_str like '182%') avg_sum_kbk182_6m

--Среднее кол-во платежей в бюджет в месяц (признак BUDGET_PAYMENT) за всю жизни компании
,(select round(avg(cnt),2)
	from (select trunc(rec.c_date,'mm') m, count(rec.id) cnt
			from z#records rec
				,z#main_docum doc
			where rec.collection_id = acc.c_arc_move
				and doc.id = rec.c_doc
				and rec.c_dt = '1'
				and doc.c_budget_payment = '1'
			group by trunc(rec.c_date,'mm'))) avg_cnt_budget_paym_all

--Среднее кол-во платежей в бюджет в месяц (признак BUDGET_PAYMENT) за шесть месяцев
,(select round(avg(cnt),2)
	from (select trunc(rec.c_date,'mm') m, count(rec.id) cnt
			from z#records rec
				,z#main_docum doc
			where rec.collection_id = acc.c_arc_move
				and doc.id = rec.c_doc
				and rec.c_dt = '1'
				and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
				and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
				and doc.c_budget_payment = '1'
			group by trunc(rec.c_date,'mm'))) avg_cnt_budget_paym_6m

--Среднее кол-во в месяц совершенных операций в бюджет с началом кода бюджетной классификации (КБК) - 182 за все время ремя жизни компании
,(select round(avg(cnt),2)
	from (select trunc(rec.c_date,'mm') m, count(rec.id) cnt
			from z#records rec
				,z#main_docum doc
			where rec.collection_id = acc.c_arc_move
				and doc.id = rec.c_doc
				and rec.c_dt = '1'
				and doc.c_bud_reqs#kbk_str like '182%'
			group by trunc(rec.c_date,'mm'))) avg_cnt_kbk182_all

--Среднее кол-во в месяц совершенных совершенных операций в бюджет с началом кода бюджетной классификации (КБК) - 182 за последние шесть месяцев
,(select round(avg(cnt),2)
		from (select trunc(rec.c_date,'mm') m, count(rec.id) cnt
			from z#records rec
				,z#main_docum doc
			where rec.collection_id = acc.c_arc_move
				and doc.id = rec.c_doc
				and rec.c_dt = '1'
				and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
				and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
				and doc.c_bud_reqs#kbk_str like '182%'
			group by trunc(rec.c_date,'mm'))) avg_cnt_kbk182_6m

--Массив назначений-сумм расход
,(select '['||listagg('{"n":"'||replace(doc.c_nazn,'"','\"')||'",'
                    ||'"s":'||replace(doc.c_sum,',','.')||'}',',') within group (order by doc.id)||']'
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
        and rownum < 5
		and doc.id = rec.c_doc
        and upper(doc.c_nazn) not like '%КОМИСС%'
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate)),-6)) array_nazn_sum_dt

--Массив назначений-сумм приход
,(select '['||listagg('{"n":"'||replace(doc.c_nazn,'"','\"')||'",'
                    ||'"s":'||replace(doc.c_sum,',','.')||'}',',') within group (order by doc.id)||']'
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
        and rownum < 5
		and doc.id = rec.c_doc
        and upper(doc.c_nazn) not like '%ДЕПОЗИТ%'
		and rec.c_dt = '0'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate)),-6)) array_nazn_sum_kt

FROM z#ac_fin acc
	,z#client cl
	,z#account acc_parent
	,z#com_status_prd st_acc
	,z#rko rko
	
WHERE acc.c_client_v = cl.id
	and acc_parent.id = acc.id
	and acc.c_com_status = st_acc.id(+)
	and rko.c_account = acc.id
	and rko.c_client = cl.id
	and cl.id = :cl_id