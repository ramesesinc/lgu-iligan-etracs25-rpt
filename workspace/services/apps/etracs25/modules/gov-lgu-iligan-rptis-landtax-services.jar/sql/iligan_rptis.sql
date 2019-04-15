[getList]
select 
	classid, classname, 
	case when special=0 then classname else concat('SPECIAL CLASS - ',classname) end as classification,  
	special, classindexno, barangayid, barangayname, barangayindexno, 
	sum(landav) as landav, sum(machav) as machav, sum(impav) as impav, sum(annualtax) as annualtax, 
	sum(basic) as basic, sum(basicint) as basicint, sum(basictotal) as basictotal, 
	sum(sef) as sef, sum(sefint) as sefint, sum(seftotal) as seftotal, sum(grandtotal) as grandtotal 
from ( 
	select 
		rl.classification_objid as classid, pc.name as classname, pc.orderno as classindexno, pc.special, 
		xx.barangayid, brgy.name as barangayname, brgy.indexno as barangayindexno, 
		xx.annualtax, xx.basic, xx.basicint, xx.basictotal, xx.sef, xx.sefint, xx.seftotal, xx.grandtotal, 
		(case when rl.rputype='land' then rl.totalav else 0.0 end) as landav, 
		(case when rl.rputype='mach' then rl.totalav else 0.0 end) as machav, 
		(case when rl.rputype in ('bldg','misc','planttree') then rl.totalav else 0.0 end) as impav 
	from ( 
		select 
			rpt.barangayid, rpt.rptledgerid, sum(rpt.basic + rpt.sef) as annualtax, 
			sum(rpt.basic) as basic, sum(rpt.basicint) as basicint, sum(rpt.basic + rpt.basicint) as basictotal,
			sum(rpt.sef) as sef, sum(rpt.sefint) as sefint, sum(rpt.sef + rpt.sefint) as seftotal,  
			sum(rpt.basic + rpt.basicint + rpt.sef + rpt.sefint) as grandtotal 
		from report_rptdelinquency rpt 
		where 1=1 ${filter} 
		group by rpt.barangayid, rpt.rptledgerid 
	)xx 
		inner join rptledger rl on xx.rptledgerid=rl.objid 
		inner join barangay brgy on xx.barangayid=brgy.objid 
		inner join faas on rl.faasid=faas.objid 
		inner join propertyclassification pc on rl.classification_objid=pc.objid 
	where rl.state='APPROVED' and faas.state='CURRENT' 
)xx 
group by classid, classname, special, classindexno, barangayid, barangayname, barangayindexno 
order by special, classindexno, classname, barangayindexno 
