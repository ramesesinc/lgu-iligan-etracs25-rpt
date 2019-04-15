[getAssessmentTaxGrossList]
select * from ( 
	select  
		applicationid, lobid, lobname, activeyear, assessmenttype,  
		sum(tax) as tax, sum(gross) as gross 
	from ( 
		select 
			br.applicationid, br.lob_objid as lobid, br.lob_name as lobname, 
			ba.appyear as activeyear, br.assessmenttype, 
			sum(br.amount) as tax, 0.0 as gross 
		from business_application ba 
			inner join business_receivable br on ba.objid=br.applicationid 
		where ba.appno=$P{appno} and br.taxfeetype='TAX' 
		group by br.applicationid, br.lob_objid, br.lob_name, ba.appyear, br.assessmenttype    

		union all 

		select 
			bi.applicationid, bi.lob_objid as lobid, bi.lob_name as lobname, 
			ba.appyear as activeyear, bal.assessmenttype, 
			0.0 as tax, sum(bi.decimalvalue) as gross 
		from business_application ba 
			inner join business_application_info bi on ba.objid=bi.applicationid 
			inner join business_application_lob bal on (ba.objid=bal.applicationid and bi.lob_objid=bal.lobid) 
		where ba.appno=$P{appno} and bi.attribute_objid='GROSS' 
		group by bi.applicationid, bi.lob_objid, bi.lob_name, ba.appyear, bal.assessmenttype 

		union all 

		select 
			br.applicationid, br.lob_objid as lobid, br.lob_name as lobname, 
			ba.appyear as activeyear, br.assessmenttype, 
			sum(br.amount) as tax, 0.0 as gross 
		from ( 
			select business_objid, appyear 
			from business_application 
			where appno=$P{appno} 
		)xx 
			inner join business_application ba on xx.business_objid=ba.business_objid 
			inner join business_receivable br on ba.objid=br.applicationid 
		where ba.appyear < xx.appyear and ba.state='COMPLETED' and br.taxfeetype='TAX' 
		group by br.applicationid, br.lob_objid, br.lob_name, ba.appyear, br.assessmenttype 

		union all 

		select 
			bi.applicationid, bi.lob_objid as lobid, bi.lob_name as lobname, 
			ba.appyear as activeyear, bal.assessmenttype, 
			0.0 as tax, sum(bi.decimalvalue) as gross 
		from ( 
			select business_objid, appyear 
			from business_application 
			where appno=$P{appno} 
		)xx 
			inner join business_application ba on xx.business_objid=ba.business_objid 
			inner join business_application_info bi on ba.objid=bi.applicationid 
			inner join business_application_lob bal on (ba.objid=bal.applicationid and bi.lob_objid=bal.lobid) 
		where ba.appyear < xx.appyear and ba.state='COMPLETED' and bi.attribute_objid='GROSS' 
		group by bi.applicationid, bi.lob_objid, bi.lob_name, ba.appyear, bal.assessmenttype  

	)xx 
	group by applicationid, lobid, lobname, activeyear, assessmenttype  
)xx 
	inner join business_application ba on xx.applicationid=ba.objid 
order by 
	xx.lobname, xx.activeyear desc, ba.txndate desc 
