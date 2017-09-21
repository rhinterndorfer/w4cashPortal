set serveroutput on; 
GRANT EXECUTE ON SYS.UTL_FILE TO W4CASH;
WHENEVER SQLERROR EXIT SQL.SQLCODE;
declare 
l_workspace_id number; 
-- command line configuration  
-- ** MODIFY WITH CAUTION - CAN BREAK/OVERWRITE OTHER APEX APPLICATIONS IF CONFIGURED WRONG ** 
l_workspace_name varchar2(100) := 'W4CASH'; 
l_application_id number := 102; 
l_parsing_schema varchar2(100) := 'W4CASH'; 
begin 
	select workspace_id into l_workspace_id 
	from apex_workspaces 
	where upper(workspace) = upper(l_workspace_name); 

	apex_application_install.set_workspace_id( l_workspace_id ); 
	apex_application_install.set_application_id(l_application_id); 
	apex_application_install.generate_offset; 
	apex_application_install.set_schema( l_parsing_schema ); 
	apex_application_install.set_application_alias( 'F' || apex_application_install.get_application_id ); 
end; 
/ 
@APEXw4cashPortal.sql 

ALTER SESSION SET CURRENT_SCHEMA = W4CASH;

@install_ir_2_excel.sql
/
exit;
