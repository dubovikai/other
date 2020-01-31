SELECT

cl.id cl_id

,cl.c_inn inn

,cl.c_name name

,st_isf.c_name isf_status

,(select props.c_str
	from z#properties props
	where props.collection_id = cl.c_add_prop
		and props.c_group_prop = 44423804542) cl_tax --::[PROPERTY_GRP]([CODE] = 'SKB_TAXATION'))

,(select frm.c_short_name
	from z#form_property frm
	where corp.c_forma = frm.id) frm_prop

,corp.c_numbers cnt_employee

,round(sysdate - corp.c_register#date_reg,1) exist_period

,(select count(*) 
    from z#skb_isf_dog where 
    c_client = cl.id) cnt_isf_dog

,(select count(*)
	from z#ac_fin acf
	where acf.c_date_close is null
		and acf.c_client_v = cl.id		
		and not exists (select 1
						from z#user_type ut
							,z#user_type_ref ut_ref
						where ut_ref.collection_id = acf.c_user_type
							and ut_ref.c_value = ut.id
							and ut.c_code = '3CARD_ACCOUNT')) acc_count

,(select count(*)
	from z#ac_fin acf
	where acf.c_client_v = cl.id) acc_count_all

,case when exists(select 1
	from z#ac_fin acf
		,z#account acnt
	where acnt.c_client_v = cl.id
		and acnt.c_date_close is null 
		and acnt.id = acf.id
		and exists (select 1
				from z#user_type ut
					,z#user_type_ref ut_ref
				where ut_ref.collection_id = acf.c_user_type
					and ut_ref.c_value = ut.id
					and ut.c_code = '3CARD_ACCOUNT'))
	then 1 else 0 end is_corp_card

,(select round(min(acnt.c_date_op - corp.c_register#date_reg),1)
	from z#ac_fin acf
		,z#account acnt
	where acnt.c_client_v = cl.id
		and acnt.id = acf.id) time_to_acc_open

,(select '['||listagg('"'||tar.c_code||'"',',') within group (order by rko.id)||']'
	from z#rko rko
		,z#period_plan pp
		,z#tarif_plan tar
		,z#product pr
	where rko.c_client = cl.id
		and pr.id = rko.id
		and rko.c_tarif_plan = pp.collection_id
		and pp.c_tar_plan = tar.id) tarifs

,(select count(*)
	from z#founders fndrs
	where fndrs.collection_id = corp.c_register#founders
		and fndrs.c_date_end is null) cnt_founders

,(select count(*)
	from z#skb_isf_mng_dog mngs
	where mngs.collection_id = isf.c_managers) cnt_mngrs

,(select count(*)
	from z#skb_isf_mng_dog mngs
	where mngs.collection_id = isf.c_managers
		and exists(select 1 
						from z#skb_isf_cert certs 
						where certs.collection_id = mngs.c_certs)) cnt_mngrs_sert

,(select decode(priv.c_sex,2047935,'M',2047936,'F',null)
	from z#persons_pos pers
		,z#cl_priv priv
	where pers.collection_id = corp.c_all_boss
		and pers.c_chief = '1'
		and priv.id = pers.c_fase) boss_gender

,(select round(MONTHS_BETWEEN(SYSDATE,priv.c_date_pers)/12,1)
	from z#persons_pos pers
		,z#cl_priv priv
	where pers.collection_id = corp.c_all_boss
		and pers.c_chief = '1'
		and priv.id = pers.c_fase) boss_age

,(select fl.c_family_cl||' '||fl.c_name_cl||' '||fl.c_sname_cl
	from z#persons_pos pers
		,z#cl_priv fl
	where pers.collection_id = corp.c_all_boss
		and pers.c_chief = '1'
		and fl.id = pers.c_fase
		and pers.c_work_end is null) boss_fio

,(select '['||listagg('"'||acf.c_main_v_id||'"',',') within group (order by acf.c_main_v_id)||']'  
	from z#persons_pos pers
		,z#ac_fin acf
		,z#account acnt
	where pers.collection_id = corp.c_all_boss
		and pers.c_chief = '1'
		and pers.c_work_end is null
		and acnt.c_date_close is null
		and acf.id = acnt.id
		and acnt.c_client_v = pers.c_fase)  boss_accs

,case when exists(select 1 
	from z#persons_pos pers
		,z#ac_fin acf
		,z#account acnt
	where pers.collection_id = corp.c_all_boss
		and pers.c_chief = '1'
		and pers.c_work_end is null
		and acnt.c_date_close is null
		and acf.id = acnt.id
		and acnt.c_client_v = pers.c_fase)
	then 1 else 0 end is_boss_acc

,(select '['||listagg('{"name":"'||fl.c_family_cl||' '||fl.c_name_cl||' '||fl.c_sname_cl||'","range":"'||casta.c_value||'"}',',') within group (order by fl.c_family_cl)||']' 
	from z#persons_pos pers
		,z#cl_priv fl
		,z#casta casta
	where pers.collection_id = corp.c_all_boss
		and casta.id = pers.c_range
		and fl.id = pers.c_fase
		and pers.c_work_end is null
		and upper(casta.c_value) like '%ÁÓÕ%') buhs

,case when exists(select 1
			from (select fl.c_family_cl||' '||fl.c_name_cl||' '||fl.c_sname_cl fio
						from z#persons_pos pers
							,z#cl_priv fl
							,z#casta casta
						where pers.collection_id = corp.c_all_boss
							and casta.id = pers.c_range
							and fl.id = pers.c_fase
							and pers.c_work_end is null
							and upper(casta.c_value) like '%BUH%') sub_buhs
					
				,(select fl.c_family_cl||' '||fl.c_name_cl||' '||fl.c_sname_cl fio
						from z#persons_pos pers
							,z#cl_priv fl
						where pers.collection_id = corp.c_all_boss
							and pers.c_chief = '1'
							and fl.id = pers.c_fase
							and pers.c_work_end is null) sub_boss
			where sub_buhs.fio = sub_boss.fio)
	then 1 else 0 end is_boss_buh

,(select '{"declare_uf":"'||c_register#declare_uf||'","paid_uf":"'||c_register#paid_uf||'"}'
	from z#cl_corp corp
	where corp.id=cl.id) capital

,(select '['||listagg('"'||disp.c_short_name||'"',',') within group (order by disp.c_short_name)||']'
	from z#str_disposition per_disp
		,z#disposition disp
	where cl.c_disposits = per_disp.collection_id
		and per_disp.c_disposition = disp.id) disp

,(select '['||listagg('"'||welf.c_name||'"',',') within group (order by welf.c_name)||']'
	from z#welf_hist whist
		,z#welfare welf
	where whist.collection_id = cl.c_welf_hist
		and whist.c_date_end is null) welfare

,cl.c_is_resident is_resident

,cl.c_nu_rezident nu_rezident

,(select '['||listagg('{"name":"'||cl_gr.c_name||'","code":"'||cl_gr.c_code||'"}',',') within group (order by cl_gr.c_code)||']'
	from z#cl_categories cl_cat
		,z#cl_group cl_gr
	where cl_cat.collection_id = cl.c_vids_cl
		and cl_cat.c_date_end is null
		and cl_cat.c_category = cl_gr.id) cl_category

,(select '['||listagg('{"name":"'||kind_limit.c_name||'","code":"'||kind_limit.c_code||'"}',',') within group (order by kind_limit.c_code)||']'
	from z#st_client cl_st
		,z#ins_restrict kind_limit
	where cl_st.collection_id = cl.c_state_stage
		and cl_st.c_date_end is null
		and cl_st.c_kind_limit = kind_limit.id) cl_limits

,case when exists(select 1
		from z#cl_block bl
			,z#cl_block_vid vid
		where bl.c_client = cl.id
			and bl.c_vid_block = vid.id
			and vid.c_code = '2'
			and bl.c_date_beg < sysdate
			and bl.c_date_end is null)
	then 'block' else 'unblock' end is_blocked

,(select '['||listagg('{"cl_id":"'||links.c_partner||'","link_code":"'||vid_link.c_code||'"}',',') within group (order by vid_link.c_code)||']'
	from z#links_cl links
		,z#cl_link vid_link
	where cl.c_links_other = links.collection_id
		and links.c_date_end is null
		and links.c_vid_link = vid_link.id) links

,(select count(*)
	from z#okved_period cl_okv
		,z#okved okv
	where cl_okv.collection_id = cl.c_okved_in_period
		and cl_okv.c_okved = okv.id
		and cl_okv.c_date_begin < sysdate
		and cl_okv.c_date_end is null) okveds_number

,(select '['||listagg('{"okv":"'||okv.c_code
		||'","p":"'||decode(cl_okv.c_primary,'1','true','0','false',null,'null',cl_okv.c_primary)
		||'","m":"'||decode(cl_okv.c_main,'1','true','0','false',null,'null',cl_okv.c_main)
		||'","mf":"'||decode(cl_okv.c_main_fsgs,'1','true','0','false',null,'null',cl_okv.c_main_fsgs)
		||'"}',',') within group (order by cl_okv.c_primary, cl_okv.c_main)||']'
	from z#okved_period cl_okv
		,z#okved okv
	where cl_okv.collection_id = cl.c_okved_in_period
		and cl_okv.c_okved = okv.id
		and cl_okv.c_date_begin < sysdate
		and cl_okv.c_date_end is null
		and rownum < 51) okveds_50

,(select okv.c_code
	from z#okved_period cl_okv
		,z#okved okv
	where cl_okv.collection_id = cl.c_okved_in_period
		and cl_okv.c_okved = okv.id
		and cl_okv.c_date_begin < sysdate
		and cl_okv.c_date_end is null
		and cl_okv.c_primary = '1'
		and cl_okv.c_main = '1') primary_okved

,(select okv.c_code
	from z#okved_period cl_okv
		,z#okved okv
	where cl_okv.collection_id = cl.c_okved_in_period
		and cl_okv.c_okved = okv.id
		and cl_okv.c_date_begin < sysdate
		and cl_okv.c_date_end is null
		and cl_okv.c_main_fsgs='1') main_fsgs_okveds

,case when exists(select 1 
	from z#overdrafts ov
		,z#pr_cred cr
		,z#product cr_pr
		,z#com_status_prd st_cr
	where cr_pr.c_com_status = st_cr.id
		and st_cr.c_code = 'WORK'
		and ov.id = cr.id
		and cr_pr.id = ov.id
		and cr.c_client = cl.id)
	then 1 else 0 end is_overdraft

FROM z#skb_isf_dog isf
	,z#product pr
	,z#client cl
	,z#cl_corp corp
	,z#cl_org org
	,z#com_status_prd st_isf

WHERE isf.id = pr.id
	and st_isf.id = pr.c_com_status
	and pr.class_id = 'SKB_ISF_DOG'
	and st_isf.c_code in ('CLOSE','WORK')
	and cl.id = isf.c_client
	and isf.id = (select max(id) from z#skb_isf_dog where c_client = cl.id)
	and cl.id = org.id
	and cl.class_id = 'CL_ORG'
	and cl.id = corp.id
