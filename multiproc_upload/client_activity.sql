SELECT

cl.id cl_id

,cl.c_inn inn

,acc.c_main_v_id acc_num

,st_acc.c_name acc_st

,acc_parent.c_date_op acc_date_open

,acc_parent.c_date_close acc_date_close

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date > add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_sum_3m

,(select count(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_count_3m

,(select min(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_min_3m

,(select max(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_max_3m

,(select (nvl(acc_parent.c_date_close,sysdate) - add_months(nvl(acc_parent.c_date_close,sysdate),-3)) - count(distinct(trunc(rec.c_date)))
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '1') dt_empty_days_3m

,(select count(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1') dt_count_all

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_sum_3m

,(select count(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_count_3m

,(select min(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_min_3m

,(select max(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_max_3m

,(select (nvl(acc_parent.c_date_close,sysdate) - add_months(nvl(acc_parent.c_date_close,sysdate),-3)) - count(distinct(trunc(rec.c_date)))
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_date >= add_months(nvl(acc_parent.c_date_close,sysdate),-3)
		and rec.c_dt = '0') kt_empty_days_3m

,(select count(*)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '0') kt_count_all

,(select trunc(avg(week.pay_count),3)
	from (select trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7) week_cnt, count(rec.c_summa_nat) pay_count
			from z#records rec
			where rec.collection_id = acc.c_arc_move
				and rec.c_date >= trunc(nvl(acc_parent.c_date_close,sysdate)) - 14
				and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate))
				and rec.c_dt = '1'
			group by trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7)) week) avg_dt_weekly_2

,(select trunc(avg(week.pay_count),3)
	from (select trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7) week_cnt, count(rec.c_summa_nat) pay_count
			from z#records rec
			where rec.collection_id = acc.c_arc_move
				and rec.c_date >= trunc(nvl(acc_parent.c_date_close,sysdate)) - 714
				and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate))
				and rec.c_dt = '1'
			group by trunc((trunc(nvl(acc_parent.c_date_close,sysdate))-trunc(c_date)) / 7)) week) avg_dt_weekly_14

,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
							and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),0),'mm'))) month_saldo_0

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-1),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),0),'mm')) month_sum_0

,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
		where rec.collection_id = acc.c_arc_move
			and rownum = 1
			and rec.c_date = (select max(rec_month.c_date)
								from z#records rec_month
								where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-1),'mm'))) month_saldo_1

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-2),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-1),'mm')) month_sum_1

,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-2),'mm'))) month_saldo_2

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-3),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-2),'mm')) month_sum_2

,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-3),'mm'))) month_saldo_3

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-4),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-3),'mm')) month_sum_3

,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-4),'mm'))) month_saldo_4

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-5),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-4),'mm')) month_sum_4

,(select rec.c_start_sum_nat + decode(rec.c_dt,'1',-1,1)*rec.c_summa_nat
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rownum = 1
		and rec.c_date = (select max(rec_month.c_date)
							from z#records rec_month
							where rec_month.collection_id = acc.c_arc_move
								and rec_month.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-5),'mm'))) month_saldo_5

,(select sum(rec.c_summa_nat)
	from z#records rec
	where rec.collection_id = acc.c_arc_move
		and rec.c_dt = '1'
		and rec.c_date >= trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-6),'mm')
		and rec.c_date < trunc(add_months(nvl(acc_parent.c_date_close,sysdate),-5),'mm')) month_sum_5

,(select trunc(min(rec.c_date)- acc_parent.c_date_op,3)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and upper(doc.c_nazn) not like '%ÊÎÌÈÑ%') pay_delay

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

,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_budget_payment = '1') cnt_budget_paym_all 

,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_budget_payment = '1') avg_sum_budget_paym_all 

,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_budget_payment = '1') cnt_budget_paym_6m 

,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_budget_payment = '1') avg_sum_budget_paym_6m 

,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_bud_reqs#kbk_str like '182%') cnt_kbk182_all

,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and doc.c_bud_reqs#kbk_str like '182%') avg_sum_kbk182_all

,(select count(*)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_bud_reqs#kbk_str like '182%') cnt_kbk182_6m

,(select round(avg(rec.c_summa),2)
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
		and doc.id = rec.c_doc
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate),'mm'),-6)
		and rec.c_date < trunc(nvl(acc_parent.c_date_close,sysdate),'mm')
		and doc.c_bud_reqs#kbk_str like '182%') avg_sum_kbk182_6m

,(select round(avg(cnt),2)
	from (select trunc(rec.c_date,'mm') m, count(rec.id) cnt
			from z#records rec
				,z#main_docum doc
			where rec.collection_id = acc.c_arc_move
				and doc.id = rec.c_doc
				and rec.c_dt = '1'
				and doc.c_budget_payment = '1'
			group by trunc(rec.c_date,'mm'))) avg_cnt_budget_paym_all

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

,(select round(avg(cnt),2)
	from (select trunc(rec.c_date,'mm') m, count(rec.id) cnt
			from z#records rec
				,z#main_docum doc
			where rec.collection_id = acc.c_arc_move
				and doc.id = rec.c_doc
				and rec.c_dt = '1'
				and doc.c_bud_reqs#kbk_str like '182%'
			group by trunc(rec.c_date,'mm'))) avg_cnt_kbk182_all

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

,(select '['||listagg('{"n":"'||replace(doc.c_nazn,'"','\"')||'",'
                    ||'"s":'||replace(doc.c_sum,',','.')||'}',',') within group (order by doc.id)||']'
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
        and rownum < 5
		and doc.id = rec.c_doc
        and upper(doc.c_nazn) not like '%ÊÎÌÈÑÑ%'
		and rec.c_dt = '1'
		and rec.c_date >= add_months(trunc(nvl(acc_parent.c_date_close,sysdate)),-6)) array_nazn_sum_dt

,(select '['||listagg('{"n":"'||replace(doc.c_nazn,'"','\"')||'",'
                    ||'"s":'||replace(doc.c_sum,',','.')||'}',',') within group (order by doc.id)||']'
	from z#records rec
		,z#main_docum doc
	where rec.collection_id = acc.c_arc_move
        and rownum < 5
		and doc.id = rec.c_doc
        and upper(doc.c_nazn) not like '%ÄÅÏÎÇÈÒ%'
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
