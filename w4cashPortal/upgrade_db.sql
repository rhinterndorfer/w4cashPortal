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
      --SYS.DBMS_OUTPUT.PUT_LINE(y);
      
      BEGIN
        select
            SUM(sd.pricebuy * sd.UNITS) / SUM(sd.UNITS),
            SUM(sd.UNITS),
            NVL((
                select SUM(NVL(UNITS,0)) from stockdiary sdi where sd.product = sdi.product and extract(year from sdi.datenew)<=y 
                and (p_date is null or y < currentyear or sdi.datenew < p_date)
              ),0)
        into
            currentPriceBuyAvg, currentUnits, currentStock
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
          currentStock := 0;
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
