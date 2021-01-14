-- ------------
-- vw_productspricegross
-- ------------
create or replace view vw_productspricegross as
select p.id, c.name as categoryname, reference, code, p.name, round(p.pricesell * (1+t.rate),5) pricegross, t.rate as taxrate
from products p 
inner join taxes t on p.taxcat=t.id
inner join categories c on p.category=c.id;
/

-- ------------
-- tr_vw_productspricegross
-- ------------
create or replace trigger tr_vw_productspricegross
 instead of update on vw_productspricegross
 referencing new as new
 begin
     update products 
      set pricesell = :new.pricegross / (1 + :new.taxrate),
        taxcat = (select id from taxes where rate = :new.taxrate)
      where id = :old.id;
     if ( sql%rowcount = 0 )
       then
         raise_application_error
          ( -20001, 'Error updating the vw_productspricegross view !!!' );
     end if;
 end;
 /

-- ------------
-- fnItemRating
-- ------------
create or replace function fnItemRating
 ( p_productid in varchar2, p_date in timestamp )
 return float
is
    pricebuy float;
    startyear number;
    currentyear number;
    lastUnits float := 0.0;
    lastPriceBuyAVG float := 0.0;
    currentUnits float;
    currentPriceBuyAvg float;
    currentStock float;
begin
    select extract(year from NVL(min(datenew),sysdate))
    into startyear
    from stockdiary where product=p_productid and datenew is not null;

    currentyear := extract(year from NVL(p_date, sysdate));

    for y in startyear..currentyear loop
      --SYS.DBMS_OUTPUT.PUT_LINE('----');
      --SYS.DBMS_OUTPUT.PUT_LINE(y);

      BEGIN
        select
            SUM(sd.pricebuy * sd.UNITS) / SUM(sd.UNITS),
            SUM(sd.UNITS)
        into
            currentPriceBuyAvg, currentUnits
        from stockdiary sd
        where
            reason in (3,4) -- Anfangsbestand, Wareneingang
            and pricebuy is not null
            and extract(year from sd.datenew)=y
            and sd.product=p_productid
            and (p_date is null or y < currentyear or sd.datenew < p_date)
        group by sd.product;
      EXCEPTION WHEN OTHERS THEN
          currentUnits := 0;
          currentPriceBuyAvg := 0;
      END;
      
      
      BEGIN
            select 
                SUM(NVL(UNITS,0)) 
            into currentStock    
            from stockdiary sdi 
            where sdi.product=p_productid   
                and extract(year from sdi.datenew)<=y
                and (p_date is null or y < currentyear or sdi.datenew < p_date);
      EXCEPTION WHEN OTHERS THEN
          currentStock := lastUnits;
      END;

      --SYS.DBMS_OUTPUT.PUT_LINE(lastUnits);
      --SYS.DBMS_OUTPUT.PUT_LINE(currentUnits);
      --SYS.DBMS_OUTPUT.PUT_LINE(lastPriceBuyAVG);
      --SYS.DBMS_OUTPUT.PUT_LINE(currentPriceBuyAvg);
      --SYS.DBMS_OUTPUT.PUT_LINE(currentStock);

      if (lastUnits + currentUnits) != 0 then
        lastPriceBuyAVG := (lastUnits * lastPriceBuyAVG + currentUnits * currentPriceBuyAvg) / (lastUnits + currentUnits);
      else
        lastPriceBuyAVG := 0;
      end if;
      lastUnits := currentStock;
    end loop;

    return lastPriceBuyAVG;
end;
/
