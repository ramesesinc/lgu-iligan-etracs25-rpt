[getList]
select 
	classid, classname, 
	case when special=0 then classname else ('SPECIAL CLASS - '+classname) end as classification,  
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
			barangayid, rptledgerid, 
			sum(basic + sef) as annualtax, 
			sum(basic) as basic, sum(basicint) as basicint, sum(basic + basicint) as basictotal, 
			sum(sef) as sef, sum(sefint) as sefint, sum(sef + sefint) as seftotal, 
			sum(basic + basicint + sef + sefint) as grandtotal 
		from ( 
			select 
				rpti.barangayid, rpti.rptledgerid, 
				case when rpti.revtype='basic' then amount else 0.0 end as basic, 
				case when rpti.revtype='basic' then interest else 0.0 end as basicint, 
				case when rpti.revtype='sef' then amount else 0.0 end as sef, 
				case when rpti.revtype='sef' then interest else 0.0 end as sefint 
			from report_rptdelinquency rpt 
				inner join report_rptdelinquency_item rpti on rpti.parentid = rpt.objid 
			where 1=1 ${filter} 
		)t1 
		group by barangayid, rptledgerid 
	)xx 
		inner join rptledger rl on xx.rptledgerid=rl.objid 
		inner join barangay brgy on xx.barangayid=brgy.objid 
		inner join faas on rl.faasid=faas.objid 
		inner join propertyclassification pc on rl.classification_objid=pc.objid 
	where rl.state='APPROVED' and faas.state='CURRENT' 
)xx 
group by classid, classname, special, classindexno, barangayid, barangayname, barangayindexno 
order by special, classindexno, classname, barangayindexno 
