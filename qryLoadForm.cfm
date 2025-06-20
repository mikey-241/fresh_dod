<cfsetting requesttimeout="999">
<cfparam name="id" default="1">
<cfparam name="SAVED_SEARCH_ID" default="">
<cfparam name="CRFTokens" default="cmsport">


<cfquery name="getForm"  datasource="#request.dsnCMDB#">
   select * from SCM_FORM where form_id = #id# 
</cfquery>
<cfif SAVED_SEARCH_ID neq "">
	<cfquery name="getTitle" datasource="DOD_Search">
        SELECT *
        FROM DOD_SAVED_SEARCH
        WHERE SAVED_SEARCH_ID = <cfqueryparam cfsqltype="cf_sql_numeric" value="#SAVED_SEARCH_ID#">
    </cfquery>
</cfif>
<cfquery name="getTeamInfo" datasource="#request.dod.dsn#">
    SELECT DBASUPPORT_TEAM_ID,DBASUPPORT_TEAM_NAME, TD_ATTUID, UNOFFICIAL_FIRST_NAME, LAST_NAME 
    FROM ODBA_TEAM_MAP, FROM_PHONE.WEBPHONE
    WHERE TD_ATTUID = SBCUID
    ORDER BY DBASUPPORT_TEAM_NAME 						
</cfquery>
<cfquery name="input_fields" datasource="#request.dsnCMDB#">
    select * from scm_field_attributes where form_id = #id# and field_mask <> 'OUTPUT' ORDER BY FIELD_ID
</cfquery>
<cfif input_fields.recordcount gt 0>
<cfoutput>
<cfset newlinn = "#chr(13)##chr(10)#">
<!--- Add 2011 check For New Report "Backup Status Report" --->
<cfif id eq '2011'>
	<cfset request.xfa = '#xfa.submit1#'>
<cfelse>
	<cfset request.xfa = '#xfa.submit#'>
</cfif>
<cfset request.dialogMessage = 'Searching DoD...'>
<cfif id eq '2005' OR id eq '2001'>
    <form id ="frm2" name="cmdbFormList" action="#myself##request.xfa#" method="post">
<cfelse>
    <form id ="frm2" name="cmdbFormList" action="#myself##request.xfa#" method="post">
</cfif>
      <input class="fg-button ui-state-default ui-corner-all" id="advanced_Search" type="button" value="Execute Report" onClick="check(this.form);">&nbsp;&nbsp;
      <!--- <input class="fg-button ui-state-default ui-corner-all" id="advanced_reset" type="button" value="Reset" onClick="$('##frm2')[0].reset();">&nbsp;&nbsp; --->
	<input class="fg-button ui-state-default ui-corner-all" type="button" name="clear" value="Reset" onclick="$('##multi-dialog-confirm').dialog('open');">&nbsp;&nbsp;
	<br /><br />
		<!--- export the report options start --->
        <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Hide Report Option Radio Button--->  
        <cfif id neq '2008'>
            <table>
                <tr>
                    <td>
                    <!--- Add onclick For New Report "Backup Status Report" --->
                    <input type="radio" onclick="jqChangeAction();" name="exporttoexcel" id="exporttoexcel" value="excel" <cfif StructKeyExists(attributes,"exporttoexcel")><cfif #attributes["exporttoexcel"]# eq "excel">checked</cfif></cfif>><b>Export To Excel</b><br/>
                    </td>
                    <td>
                    <!--- Add onclick For New Report "Backup Status Report" --->
                    <input type="radio" onclick="jqChangeAction();" name="exporttoexcel" id="exporttoexcel" value="html" <cfif StructKeyExists(attributes,"exporttoexcel")><cfif #attributes["exporttoexcel"]# eq "html">checked</cfif><cfelse>checked</cfif>><b>Results To HTML</b><br/>
                    </td>
                </tr>
            </table>
        </cfif>    
        <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Hide Report Option Radio Button--->    
		<!--- export report options end ---><!--- Add 2011 check For New Report "Backup Status Report" --->
    <div class="dodBoxes ui-corner-all">
        <div class="dodBoxTitle ui-corner-all" style="float:left;">Search Criteria:</div>
		<input type="hidden" name="do" id="do" value="#request.xfa#" />
        <!--- Add hidden field For New Report "Backup Status Report" --->
        <input type="hidden" name="searchfrmId" id="searchfrmId" value="#id#" />
        <input type="hidden" name="EditUpdate" id="EditUpdate" value="">
		<!---<input name="secTokensID" type="hidden" value="#CSRFTOKEN#" />--->
        <cfset CRFTokens=encrypt("cmsport", "H3nTw8wxZbsTP0G1zVb3lw==", "CFMX_COMPAT", "base64")>
		<cfoutput><input name="secTokensID" type="hidden" value="#CRFTokens#" /></cfoutput>
        
       <table border=0 align="left">
	   <tr><td colspan="2"></td></tr>
       <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Input Option--->  
       		<cfif id eq '2008'>
                <tr>
                <td style="font-weight:bold;">
                <div style="float:left;width:100px">
                    Search Item:&nbsp;
                    <img src="../assets/images/ques_mrk.png" onclick="showDescript('Search on multiple fields to determine the asset.');" />&nbsp; 
                 </div>   
                </td>
                <td> 
                <div style="float:left;width:290px" >
                    <input type="text" size="18" name="search_item" id="search_item" />
                   
                    <select name="match_condition" id="match_condition">
                        <option value="starts with">starts with</option>
                        <option value="equals">equals</option>
                        <option value="contains">contains</option>
                    </select>
               </div>
                   </td>
               </tr>
               <table border=0 >
                    <tr>
                        <td style="text-decoration:underline">
                            Search Item restriction:
                        </td>
                        <td align="left">
                        	 Input value must be at least 3 characters in length.
                        </td>
                    </tr>
                   <tr>
                       <td style="text-decoration:underline">
                         	Search Item is searched against the following fields:
                       </td> 
                       <td>
                       		 Application Acronym, Application Name, CI Name Instance, Database Name, Net Service Name, Physical Server and Virtual Server.
                       </td>                   
                   </tr>
              </table>
        <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Input Option--->  
           	<cfelse>
        <!--- Get Fields to display on this form --->
        	
            <cfloop query="input_fields">
                <!--- Display select fields as select and pull option list from scm_field_values--->
              <cfif input_fields.field_type eq 'SELECT' OR input_fields.field_type eq 'MULTISELECT'>
                    <!---get label descript--->
                        <cfquery name="getDescript" datasource="#request.dod.dsn#">
                            SELECT DESCRIPTION, VALID_LABEL_ID
                            FROM AUTOSRM_SOFTDATA.VALID_LABELS
                            WHERE COLUMN_NAME = '#input_fields.atrium_name#'
                        </cfquery>
			  
              <tr><td style="font-weight:bold;">
                    #input_fields.field_name#:&nbsp;
                    <cfif #getDescript.description# neq ''>
                        <img src="../assets/images/ques_mrk.png"  onclick="showDescript(#getDescript.VALID_LABEL_ID#);" />&nbsp;
                   </cfif>
                    </td><td id="field-WHERE-#input_fields.atrium_name#">
                <cfif input_fields.field_name eq 'Support Organization' OR input_fields.field_name eq 'DBA Support Organization'>
                    <select name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" style="width:#input_fields.field_length#px;" <cfif input_fields.field_type eq 'MULTISELECT'>multiple="multiple" value=""</cfif>>
                    <cfif input_fields.field_type neq 'MULTISELECT'>
                     <option value=""></option>
                    </cfif>
                    <cfquery name="getOrgs" datasource="#request.dod.dsn#">
                        SELECT ORG_ID FROM SUPPORT_ORGS ORDER BY ORG_ID
                    </cfquery>
                    <cfloop query="getOrgs">
						<!--- Code Changes for Ticket Id - 1729011 by PW4770 Starts --->
                        <option value="#getOrgs.ORG_ID#"
                            <cfif input_fields.field_type eq 'MULTISELECT'>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                    <cfif #ListFind(attributes["WHERE-#input_fields.atrium_name#"],"#getOrgs.ORG_ID#")#>selected</cfif>
                                </cfif>
                            <cfelse>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                <cfif #attributes["WHERE-#input_fields.atrium_name#"]# eq "#getOrgs.ORG_ID#">selected="selected"</cfif>
                                </cfif>
                            </cfif>>#getOrgs.ORG_ID#</option>
						<!--- Code Changes for Ticket Id - 1729011 by PW4770 Ends --->
                    </cfloop>
			<!--- PPM - 1571562 Start --->
				<cfelseif input_fields.field_name eq 'DBA Team Managers'>
					<select name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" style="width:265px;" <cfif input_fields.field_type eq 'MULTISELECT'>multiple="multiple" value=""</cfif>>
					<cfif input_fields.field_type neq 'MULTISELECT'>
                     <option value=""></option>
                    </cfif>
					<!--- Code Changes for Ticket Id - 1729011 by PW4770 Starts --->
					<cfif StructKeyExists(attributes,"WHERE-DBASUPPORT_ORG")>
						<cfset tmpDBASupOrg= attributes["WHERE-DBASUPPORT_ORG"]>
					</cfif>
 
					<cfquery name="getDBATeam" datasource="#request.dod.dsn#">
                          SELECT distinct(TD_ATTUID),UNOFFICIAL_FIRST_NAME, LAST_NAME 
							FROM ODBA_TEAM_MAP, FROM_PHONE.WEBPHONE where TD_ATTUID = SBCUID 
                            <cfif StructKeyExists(attributes,"WHERE-DBASUPPORT_ORG")>
								and DBASUPPORT_ORG IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpDBASupOrg#" list="yes">)
                            </cfif>
							ORDER BY LAST_NAME 
                    </cfquery>
					<cfloop query="getDBATeam">
						<option value="#getDBATeam.TD_ATTUID#"
                            <cfif input_fields.field_type eq 'MULTISELECT'>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                    <cfif #ListFind(attributes["WHERE-#input_fields.atrium_name#"],"#getDBATeam.TD_ATTUID#")#>selected</cfif>
                                </cfif>
                            <cfelse>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                	<cfif #attributes["WHERE-#input_fields.atrium_name#"]# eq "#getDBATeam.TD_ATTUID#">selected="selected"</cfif>
                                </cfif>
                            </cfif>>#getDBATeam.LAST_NAME#, #getDBATeam.UNOFFICIAL_FIRST_NAME# (#getDBATeam.TD_ATTUID#)</option>
						<!--- Code Changes for Ticket Id - 1729011 by PW4770 Ends --->
                    </cfloop>
				<cfelseif input_fields.field_name eq 'DBA Team Name'>
					<select name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" style="width:265px;" <cfif input_fields.field_type eq 'MULTISELECT'>multiple="multiple" value=""</cfif>>
					<cfif input_fields.field_type neq 'MULTISELECT'>
                     <option value=""></option>
                    </cfif>
					<!--- Code Changes for Ticket Id - 1729011 by PW4770 Starts --->
					<cfif StructKeyExists(attributes,"WHERE-DBA_SUPPORT_TEAM_TD_ATTUID")>
						<cfset tmpDBATD_ATTUID= attributes["WHERE-DBA_SUPPORT_TEAM_TD_ATTUID"]>
					<cfelseif StructKeyExists(attributes,"WHERE-DBASUPPORT_ORG")>
						<cfset tmpDBASupOrg= attributes["WHERE-DBASUPPORT_ORG"]>
					</cfif>
						
					<cfquery name="getTeamName" datasource="#request.dod.dsn#">
                          SELECT DBASUPPORT_TEAM_ID,DBASUPPORT_TEAM_NAME, TD_ATTUID, UNOFFICIAL_FIRST_NAME, LAST_NAME 
                          FROM ODBA_TEAM_MAP, FROM_PHONE.WEBPHONE where TD_ATTUID = SBCUID 
                            <cfif StructKeyExists(attributes,"WHERE-DBA_SUPPORT_TEAM_TD_ATTUID")>
								and TD_ATTUID IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpDBATD_ATTUID#" list="yes">)
							<cfelseif StructKeyExists(attributes,"WHERE-DBASUPPORT_ORG")>
								and DBASUPPORT_ORG IN (<cfqueryparam cfsqltype="cf_sql_varchar" value="#tmpDBASupOrg#" list="yes">)
							</cfif>
							order by DBASUPPORT_TEAM_NAME				
					</cfquery>				
                      
					<cfloop query="getTeamName">
						
                        <option value="#getTeamName.DBASUPPORT_TEAM_NAME#"
                            <cfif input_fields.field_type eq 'MULTISELECT'>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                    <cfif #ListFind(attributes["WHERE-#input_fields.atrium_name#"],"#getTeamName.DBASUPPORT_TEAM_NAME#")#>selected</cfif>
                                </cfif>
                            <cfelse>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                <cfif #attributes["WHERE-#input_fields.atrium_name#"]# eq "#getTeamName.DBASUPPORT_TEAM_NAME#">selected="selected"</cfif>
                                </cfif>
                            </cfif>>#getTeamName.DBASUPPORT_TEAM_NAME# (#getTeamName.DBASUPPORT_TEAM_ID#)</option>
					</cfloop>
					<!--- Code Changes for Ticket Id - 1729011 by PW4770 Ends --->
			<!--- PPM - 1571562 End --->
                <cfelseif input_fields.field_name eq 'DBA Name' AND id eq '2005'>
                <!--- Select list of Primary DBAs --->
                 <select name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" style="width:265px;" <cfif input_fields.field_type eq 'MULTISELECT'>multiple="multiple" value=""</cfif>>
                    <cfquery name="getDBAs" datasource="#request.dod.dsn#"> <!--- "blockfactor="20" maxrows="20" " Removed by preeti for PPM#1215309  --->
                    Select distinct sbcuid as suits_id,last_name,unofficial_first_name,lower(last_name) as lln from 
					(
						SELECT DISTINCT sbcuid,last_name,unofficial_first_name
  						FROM FROM_PHONE.WEBPHONE a ,autosrm_support.merged_drilldown_v b
 						WHERE  b.PRIMARY_attuid  = a.sbcuid
 						UNION 
						SELECT DISTINCT sbcuid,last_name,unofficial_first_name
  						FROM FROM_PHONE.WEBPHONE a ,autosrm_support.merged_Drilldown_nondb_v b
 						WHERE b.PRIMARY_attuid  = a.sbcuid
					) order by UPPER(last_name)
                    </cfquery>
                    
                    <cfloop query="getDBAs">
                        <option value="#getDBAs.suits_id#"
                            <cfif input_fields.field_type eq 'MULTISELECT'>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                    <cfif #ListContains(attributes["WHERE-#input_fields.atrium_name#"],"#getDBAs.suits_id#")#>selected</cfif>
                                </cfif>
                            <cfelse>
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                <cfif #attributes["WHERE-#input_fields.atrium_name#"]# eq "#getDBAs.suits_id#">selected="selected"</cfif>
                                </cfif>
                            </cfif>>#getDBAs.last_name#, #getDBAs.unofficial_first_name# (#getDBAs.suits_id#)</option>
                    </cfloop>
                <cfelseif id eq '2009'>
                <!--- Select list of Primary DBAs --->
                <select name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" style="width:265px;" <cfif input_fields.field_type eq 'MULTISELECT'>multiple="multiple" value=""</cfif>>
                    <cfquery name="relationshipTypes" datasource="#request.dod.dsn#" >
                        select distinct valid_value from autosrm_softdata.valid_values where column_name ='RELATIONSHIP_TYPE'And active_flag='Y' order by valid_value
                    </cfquery>
                    <cfloop query="relationshipTypes">
                        <option value="#relationshipTypes.valid_value#"
                                <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>
                                    <cfif #ListContains(attributes["WHERE-#input_fields.atrium_name#"],"#relationshipTypes.valid_value#")#>selected</cfif>
                                </cfif>>
                            #relationshipTypes.valid_value#</option>
					</cfloop>    
                <cfelse>
                <!---<cfif id eq 2007><cfoutput>#input_fields.atrium_name#</cfoutput></cfif>--->
                <select name="WHERE-#trim(input_fields.atrium_name)#" id="WHERE-#trim(input_fields.atrium_name)#" style="width:#input_fields.field_length#px;" <cfif input_fields.field_type eq 'MULTISELECT'>multiple="multiple" value=""</cfif>>
                <cfif input_fields.field_type neq 'MULTISELECT'>
                 <option value=""></option>
                </cfif>
                <!---report 2006 and 2007 only want Orace to appear in RDBMS_TYPE dropdown--->
                <cfif input_fields.atrium_name eq 'RDBMS_TYPE' AND id eq 2007>
                     <cfquery dbtype="query" name="vv">
                        select * from application.DoDValidValues where column_name = '#trim(input_fields.atrium_name)#' and valid_value = 'ORACLE'
                    </cfquery>
				<!--- Add 2011 For New Report "Backup Status Report" --->
                <cfelseif (input_fields.atrium_name eq 'RDBMS_TYPE' AND id eq 2006) OR (input_fields.atrium_name eq 'RDBMS_TYPE' AND id eq 2011)>
                     <cfquery dbtype="query" name="vv">
                        select * from application.DoDValidValues where column_name = '#trim(input_fields.atrium_name)#' and valid_value = 'ORACLE'
                    </cfquery>
                <cfelse>
					<!---code changes for Ticket Id - 1677748 by PW4770 Starts --->
                    <cfquery dbtype="query" name="vv">
                        select * from application.DoDValidValues where column_name = '#trim(input_fields.atrium_name)#' order by VALID_VALUE ASC
                    </cfquery>
					<!---code changes for Ticket Id - 1677748 by PW4770 Ends --->
                </cfif>
                <cfloop query="vv">
                            
                            <!---for report 2006 and 2007, Oracle should be the default for RDBMS_TYPE--->
                            <!--- Add 2011 For New Report "Backup Status Report" --->
                            <cfif id eq 2007 AND input_fields.atrium_name eq 'RDBMS_TYPE'>
                                 <option value="#vv.valid_value#" selected="selected">#vv.valid_value#</option>
                            <cfelseif (id eq 2006 AND input_fields.atrium_name eq 'RDBMS_TYPE') OR (id eq 2011 AND input_fields.atrium_name eq 'RDBMS_TYPE')>
                                 <option value="#vv.valid_value#" selected="selected">#vv.valid_value#</option>
                            
                            <cfelse>
                               <option value="#vv.valid_value#" 
                                <cfif input_fields.field_type eq 'MULTISELECT'>
                                    <cfif StructKeyExists(attributes,"WHERE-#trim(input_fields.atrium_name)#")>
                                        <cfif #ListContains(attributes["WHERE-#trim(input_fields.atrium_name)#"],"#vv.valid_value#")#>selected</cfif>
                                    <cfelse>
                                        <cfif SAVED_SEARCH_ID eq ""><cfif vv.field_default eq 'Y'>selected</cfif></cfif>
                                    </cfif>
                                <cfelse>
                                    <cfif StructKeyExists(attributes,"WHERE-#trim(input_fields.atrium_name)#")>
                                    <cfif #attributes["WHERE-#trim(input_fields.atrium_name)#"]# eq "#vv.valid_value#">selected="selected"</cfif>
                                    </cfif>
                                </cfif>
                                >#vv.valid_value#</option>
                               </option>
                               </cfif>
                </cfloop>
                </cfif>
                </select>
                <input type="hidden" name="EVAL-#trim(input_fields.atrium_name)#" id="EVAL-#trim(input_fields.atrium_name)#" <cfif input_fields.field_type eq 'MULTISELECT'>value="in"<cfelse>value="equals"</cfif> />
                <cfif input_fields.field_type eq 'MULTISELECT'>
                    <script type="text/javascript">
                        $(document).ready(function() {
                            $("##WHERE-#input_fields.atrium_name#").multiselect({
                               selectedText: "## of ## selected"
                            });
                        });
                </script>
                </cfif>
              </td></tr>
                <!--- Display hidden fields as hidden and pull default value from scm_field_values--->
                
              <cfelseif input_fields.field_type eq 'HIDDEN'>
                <cfquery name="field_options" datasource="#request.dsnCMDB#">select * from scm_field_values where field_id = #input_fields.field_id#</cfquery>
                <input type="#lcase(input_fields.Field_Type)#" name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" value="#field_options.Field_Value#" />
              <cfelse>
               <!---check for label descript--->
               <cfquery name="getDescript" datasource="#request.dod.dsn#">
                    SELECT DESCRIPTION, VALID_LABEL_ID
                    FROM AUTOSRM_SOFTDATA.VALID_LABELS
                    WHERE COLUMN_NAME = '#input_fields.atrium_name#'
               </cfquery>
                <tr><td style="font-weight:bold;">
                <div <cfif id eq 2009> style="float:left;width:120px"</cfif>>
                    #input_fields.field_name#:&nbsp;<cfif #getDescript.description# neq ''>
                    <img src="../assets/images/ques_mrk.png" onclick="showDescript(#getDescript.VALID_LABEL_ID#);" />&nbsp; 
                 </div>                
               </cfif></td><td id="field-WHERE-#input_fields.atrium_name#">
               
               <div <!---style="width:273px;"--->>
                	<!--- Changes for Reuqest #1218234 for report 2001,2005,2006,2007--->
                    <!--- Add 2011 For New Report "Backup Status Report" --->
                   <cfif (attributes.id EQ 2005 OR attributes.id EQ 2001 OR attributes.id EQ 2006 OR attributes.id EQ 2007 OR attributes.id EQ 2011) AND input_fields.Field_Name NEQ "Reporting Time Frame">
                        <div id="DivWHERE-#input_fields.atrium_name#"style="float: left;margin: 0 2px 0 0;width: 181px;"> 
                        	<input class="<cfif input_fields.field_type eq 'TEXT'>alpha<cfelse>numeric</cfif>" type="#lcase(input_fields.Field_Type)#" onChange="$(this).val(jQuery.trim($(this).val()));" size="25" maxlength="#input_fields.field_length#" name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>value="#attributes["WHERE-#input_fields.atrium_name#"]#"</cfif> <cfif input_fields.field_mask eq 'ATTUID' OR input_fields.field_mask eq 'MOTSID' OR input_fields.field_mask eq 'ITAPIDENTITY' OR input_fields.field_mask eq 'MOTSACRON' OR input_fields.field_mask eq 'PRINAME' OR input_fields.field_mask eq 'BACKNAME' OR input_fields.field_mask eq 'DBNAME' OR input_fields.field_mask eq 'SERVERNAME' OR input_fields.field_mask eq 'IPADDRESS' OR input_fields.field_mask eq 'VERSION_NUMBER'> onchange="$('##WHERE-#input_fields.atrium_name#-search_div').hide();"</cfif>/>
                		</div>
                     <!--- Add Reporting Time Frame For New Report "Backup Status Report" --->
                	<cfelseif input_fields.Field_Name NEQ "Reporting Time Frame">
						<input class="<cfif input_fields.field_type eq 'TEXT'>alpha<cfelse>numeric</cfif>" type="#lcase(input_fields.Field_Type)#" onChange="$(this).val(jQuery.trim($(this).val()));" size="25" maxlength="#input_fields.field_length#" name="WHERE-#input_fields.atrium_name#" id="WHERE-#input_fields.atrium_name#" <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")>value="#attributes["WHERE-#input_fields.atrium_name#"]#"</cfif> <cfif input_fields.field_mask eq 'ATTUID' OR input_fields.field_mask eq 'MOTSID' OR input_fields.field_mask eq 'ITAPIDENTITY' OR input_fields.field_mask eq 'MOTSACRON' OR input_fields.field_mask eq 'PRINAME' OR input_fields.field_mask eq 'BACKNAME' OR input_fields.field_mask eq 'DBNAME' OR input_fields.field_mask eq 'SERVERNAME' OR input_fields.field_mask eq 'IPADDRESS' OR input_fields.field_mask eq 'VERSION_NUMBER'> onchange="$('##WHERE-#input_fields.atrium_name#-search_div').hide();"</cfif>/>
					</cfif>
                    <!--- Add Reporting Time Frame For New Report "Backup Status Report" --->
                    <cfif input_fields.Field_Name EQ "Reporting Time Frame" AND attributes.id EQ 2011>
                    	<input class="alpha" type="#lcase(input_fields.Field_Type)#" name="WHERE-#input_fields.atrium_name#" style="width: 30px;" id="WHERE-#input_fields.atrium_name#" maxlength="3" <cfif StructKeyExists(attributes,"WHERE-#input_fields.atrium_name#")> value='#attributes["WHERE-#input_fields.atrium_name#"]#' <cfelse> value="5" </cfif>> (days back)
                        <input type="hidden" name="EVAL-#trim(input_fields.atrium_name)#" id="EVAL-#trim(input_fields.atrium_name)#" value="equals"/>
                        <script type="text/javascript">
							$(document).ready(function() {
								$('##field-WHERE-CREATE_DATE').bind('keypress', function (event) {
									var key = !event.charCode ? event.which : event.charCode;
									if ((key >=48 && key <= 57) // digits
									|| key == 0 // CTRL+F5
									|| key == 8 // backspace
									|| key == 27 // escape
									|| key == 32 // Space
									//|| key == 45 // Dash
									//|| key == 46 // period
									//|| key == 95 // Underscore
									//|| key == 99 // CTRL+c
									//|| key == 118 // CTRL+v
									//|| key == 120 // CTRL+x
									) {}else{
									 event.preventDefault();
									   return false;
									}
								});
							});
						</script>
                    </cfif>
                    
                    <!--- Add 2011 and Reporting Time Frame check For New Report "Backup Status Report" --->
                   <cfif input_fields.Field_Name NEQ "Reporting Time Frame">
                    <select name="EVAL-#input_fields.atrium_name#" id="EVAL-#input_fields.atrium_name#" <cfif attributes.id EQ 2005 OR attributes.id EQ 2001 OR attributes.id EQ 2006 OR attributes.id EQ 2007 OR attributes.id EQ 2011> onChange="text2textarea(this,'WHERE-#input_fields.atrium_name#','#input_fields.field_length#','#input_fields.field_mask#')"</cfif>>
                    <cfif input_fields.field_type eq 'TEXT'>
                        <option value="starts with" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "starts with">selected</cfif></cfif>>starts with</option>
                        <option value="equals" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "equals">selected</cfif></cfif>>equals</option>
                        <option value="contains" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "contains">selected</cfif></cfif>>contains</option>
                        <cfif attributes.id EQ 2005>
                        	<cfif input_fields.atrium_name eq 'CI_NAME_INSTANCE'  OR input_fields.atrium_name eq 'PHYSICAL_SERVER_NAME' OR input_fields.atrium_name eq 'MOTS_ID'OR input_fields.atrium_name eq 'VERSION_NUMBER'>
                        		<option value="List" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "List">selected</cfif></cfif>>List</option>
                        	</cfif>
						<!--- Add 2011 For New Report "Backup Status Report" --->
                        <cfelseif attributes.id EQ 2001 OR attributes.id EQ 2006 OR attributes.id EQ 2007 OR attributes.id EQ 2011>
                        	<cfif input_fields.atrium_name eq 'VERSION_NUMBER'>
                            	<option value="List" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "List">selected</cfif></cfif>>List</option>
                        	</cfif>
                        </cfif>
						<cfif attributes.id EQ 2011>
							<cfif input_fields.atrium_name eq 'PHYSICAL_SERVER_NAME' OR input_fields.atrium_name eq 'CI_NAME_INSTANCE' OR input_fields.atrium_name eq 'MOTS_ID' OR input_fields.atrium_name eq 'APPCONTACT'>
								<option value="List" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "List">selected</cfif></cfif>>List</option>
							</cfif>
						</cfif>
                    <!--- END Changes for Reuqest #1218234 for report 2001,2005,2006,2007--->
                    <cfelse>
                        <option value="gte" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "gte">selected</cfif></cfif>>>=</option>
                        <option value="eq" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "equals">selected</cfif></cfif>>equals</option>
                        <option value="lte" <cfif StructKeyExists(attributes,"EVAL-#input_fields.atrium_name#")><cfif #attributes["EVAL-#input_fields.atrium_name#"]# eq "lte">selected</cfif></cfif>><=</option>
                    </cfif>
                    </select>
                    </cfif>
              </div>
                    <!--- Add extra div if field is ATTUID or MOTS or ITAPIDENTITY--->
                    <!---Changes for Request #1218234--->
                    <cfif input_fields.field_mask eq 'ATTUID' OR input_fields.field_mask eq 'MOTSID' OR input_fields.field_mask eq 'ITAPIDENTITY' OR input_fields.field_mask eq 'MOTSACRON' OR input_fields.field_mask eq 'PRINAME' OR input_fields.field_mask eq 'BACKNAME' OR input_fields.field_mask eq 'DBNAME' OR input_fields.field_mask eq 'SERVERNAME' OR input_fields.field_mask eq 'IPADDRESS' OR input_fields.field_mask eq 'VERSION_NUMBER'><!--- END Changes for Reuqest #1218234--->
                        <div id="WHERE-#input_fields.atrium_name#-search_div" style="position:absolute;background:##dddddd;width:270px;display:none;z-index:10;"></div>
                        <script type="text/javascript">
                        $(document).ready(function() {
                            $('##WHERE-#input_fields.atrium_name#').bind('keyup', function () {
                                var searchBox = $(this);
                                var criteria = searchBox.val();
                                var resultsContainer = $("##WHERE-#input_fields.atrium_name#-search_div");
								if(criteria.length <= 3){resultsContainer.html('');resultsContainer.hide();return;}
								
								
                                var search_request = searchBox.data('request_object');
                                
                                //If a search is currently running, stop it before starting a new search
                                if(search_request != null){search_request.abort();}
                                
                                searchBox.data('request_object', $.ajax({
                                    type: 'get',
                                    url: '<cfoutput>#myself##xfa.qryDoDPerson#</cfoutput>',
                                    /*Start -- Request 1027104 -- passing additional data 'Id'*/
                                    data: 'q=' + encodeURIComponent(criteria) + '&f=' + $(this).attr("id") + '&m=#input_fields.field_mask#' + '&id=' + #id#,
                                    /*End -- Request 1027104 -- passing additional data 'Id'*/
                                    beforeSend: function(){resultsContainer.show();resultsContainer.html('Please Wait... (Continue Typing to Refine Search).');},
                                    success: function(data,status,xhr){
                                        searchBox.data('request_object',null);
                                        resultsContainer.html(data);
                                    },	
                                    error: function(request, err, errorThrown){
                                        request.abort();
                                        searchBox.data('request_object', null);
                                    }
                                }));
                            });
                        });
                    
                        </script>
                    </cfif>
                        
                    <!--- If Field is CI_NAME_INSTANCE apply function for CI_DATABASE_NAME --->
                    <cfif input_fields.atrium_name eq 'CI_NAME_INSTANCE'>
                    <div id="WHERE-#input_fields.atrium_name#-search_div" style="position:absolute;background:##dddddd;width:270px;display:none;z-index:10;"></div>
                        <script type="text/javascript">
                        $(document).ready(function() {
                            $('##WHERE-#input_fields.atrium_name#').bind('keyup', function () {
                                var searchBox = $(this);
                                var criteria = searchBox.val();
                                //var resultsContainer = $("##field-WHERE-CI_NAME");
								var resultsContainer = $("##WHERE-#input_fields.atrium_name#-search_div");
    							// Don't search for less than 3 chars, else restore field
								if(criteria.length <= 3){resultsContainer.html('');resultsContainer.hide();return;}
                                
                                var search_request = searchBox.data('request_object');
                                
                                //If a search is currently running, stop it before starting a new search
                                if(search_request != null){search_request.abort();}
                                
                                searchBox.data('request_object', $.ajax({
                                    type: 'get',
                                    url: '<cfoutput>#myself##xfa.qryDoDPerson#</cfoutput>',
                                    data: 'q=' + encodeURIComponent(criteria) + '&f=' + $(this).attr("id") + '&m=#input_fields.atrium_name#' ,
                                    beforeSend: function(){resultsContainer.show();resultsContainer.html('Please Wait... (Continue Typing to Refine Search).');},
                                    success: function(data,status,xhr){
                                        searchBox.data('request_object',null);
										
                                        resultsContainer.html(data);
                                    },	
                                    error: function(request, err, errorThrown){
                                        request.abort();
                                        searchBox.data('request_object', null);
                                    }
                                }));
                            });
                        });
                    
                        </script>
                    </cfif>
                </td></tr>
             </cfif>
            </cfloop>
            </cfif>
		</table>
        </div>
        
      <!--- Padding --->
       <div style="float:left; padding:10px;"></div>
       
        <!--- Get the output fields --->
        <cfquery name="output_fields" datasource="#request.dsnCMDB#">
    		select * from scm_field_attributes where form_id = #id# and field_mask = 'OUTPUT' and form_id <> 2008 and active='1'
			<cfif id eq '2005'>
            	ORDER BY FIELD_NAME
            <cfelseif id eq '2001'>
            	ORDER BY ATRIUM_NAME
            <!--- Start conmdition add to get records in orders ps153p --->
            <cfelseif id eq '2009'>
               ORDER BY FIELD_ID,FIELD_NAME
            <!---END --->
            <cfelse>
	            ORDER BY FIELD_ID
            </cfif>
		</cfquery>
        <cfif output_fields.recordcount gt 0>
            <div class="dodBoxes ui-corner-all">
            <div class="dodBoxTitle ui-corner-all">Output Fields:</div>
            <input type="checkbox" id="0" class="checkall <cfif request.vtip>vtip</cfif>" <cfif request.vtip>title="Click to check all checkboxes"</cfif> name="checkall" value="1" <cfif StructKeyExists(attributes,"checkall")><cfif #attributes["checkall"]# eq 1>checked</cfif></cfif>/> <strong style="font-size:14px;">Check All</strong><br />
            <div id="myDiv">
		   <cfloop query="output_fields">
           
           <!---check for label descript--->
           <cfquery name="getDescript" datasource="#request.dod.dsn#">
           		SELECT DESCRIPTION, VALID_LABEL_ID
                FROM AUTOSRM_SOFTDATA.VALID_LABELS
	            WHERE COLUMN_NAME = '#output_fields.atrium_name#'
           </cfquery>
           <cfif  ("#output_fields.DESCRIPTION#" neq '')>
	           <cfset act_desc =  "#output_fields.DESCRIPTION#">
               
            <cfelse>
                  <cfset act_desc =  "#getDescript.DESCRIPTION#">
           </cfif>
           <cfset act_desc = replaceNoCase('#act_desc#', chr(10), " ", "all")>
			<cfset act_desc = replaceNoCase('#act_desc#', chr(13), " ", "all")>
            <cfset act_desc = replaceNoCase('#act_desc#', chr(34), " ", "all")>
            <cfset act_desc = replaceNoCase('#act_desc#', chr(39), " ", "all")>
            <cfset VALID_LABEL_ID = replaceNoCase('#getDescript.VALID_LABEL_ID#', chr(10), " ", "all")>
			<cfset VALID_LABEL_ID = replaceNoCase('#getDescript.VALID_LABEL_ID#', chr(13), " ", "all")>
            <cfset VALID_LABEL_ID = replaceNoCase('#getDescript.VALID_LABEL_ID#', chr(34), " ", "all")>
            <cfset VALID_LABEL_ID = replaceNoCase('#getDescript.VALID_LABEL_ID#', chr(39), " ", "all")>
            &nbsp;&nbsp;<input type="checkbox" name="SELECT-#output_fields.atrium_name#" id="SELECT-#output_fields.atrium_name#" value="1" <cfif StructKeyExists(attributes,"SELECT-#output_fields.atrium_name#")>checked</cfif> /> <strong>#output_fields.field_name#</strong>
            
            
            <cfif #act_desc# neq ''>
           	<!---	<img src="../assets/images/ques_mrk.png" onclick="showDescript(#getDescript.VALID_LABEL_ID#);" /> --->
            	<img src="../assets/images/ques_mrk.png" onclick="showActDescript('#act_desc#');" /> 
           <cfelse>
       	        <img src="../assets/images/ques_mrk.png" onclick="showDescript('#getDescript.VALID_LABEL_ID#');" /> 
           </cfif>
          
            <br />
            </cfloop>
			</div>
            </div>
        </cfif>
        <div style="clear:both;">
        <br />
          <input class="fg-button ui-state-default ui-corner-all" id="advanced_Search" type="button" value="Execute Report" onClick="check(this.form);">&nbsp;&nbsp;
          <!--- <input class="fg-button ui-state-default ui-corner-all" id="advanced_reset" type="button" value="Reset" onClick="$('##frm2')[0].reset();">&nbsp;&nbsp; --->
		<input class="fg-button ui-state-default ui-corner-all" type="button" name="clear" value="Reset" onclick="$('##multi-dialog-confirm').dialog('open');">&nbsp;&nbsp;
          <input type="hidden" id="searchform" name="searchform" value="#id#" />
		</div>
 
 		 <div id="lblDescript" title="Description" style="display:none" >
            </div>
    	

</form>


<script type="text/javascript">

	$(document).ready(function() {
		
		$('##lblDescript').dialog({
			autoOpen: false,
		    modal: true,
			resizable: false,
			width: 400,
			buttons: {
				"Ok": function() {
					$(this).dialog("close");
				}
			}
		});
		
		
		$('.fg-button').uiBtn();
		<cfif SAVED_SEARCH_ID eq "">
			$('##pageTitle').html('#getForm.Form_Name#');
		<cfelse>
			$('##pageTitle').html('Edit #getTitle.SAVED_SEARCH_NAME#');
			$('##EditUpdate').val(#SAVED_SEARCH_ID#);
		</cfif>

		
		//If enter is pressed, submit search form.
		//updated by cm4283 9/6/2013
	<!--- Changes for 1218234--->
	<cfif attributes.id neq 2005>
		$(document).keyup(function(event) {
			if (event.keyCode == 13 && !$(event.target).is("textarea")) {
				$("##advanced_Search").click();
			}
		});
		
	</cfif>
	<!--- END of Changes for 1218234--->
	
	// *** Function to only allow certain characters ***
		$('.numeric').bind('keypress', function (event) {
			var key = !event.charCode ? event.which : event.charCode;
			if ((key >=48 && key <= 57) // digits
			|| key == 0 // CTRL+F5
			|| key == 8 // backspace
			|| key == 27 // escape
			|| key == 32 // Space
			|| key == 45 // Dash
			|| key == 46 // period
			|| key == 95 // Underscore
			|| key == 99 // CTRL+c
			|| key == 118 // CTRL+v
			|| key == 120 // CTRL+x
			) {}else{
			 event.preventDefault();
			   return false;
			}
		});
		
	// *** Function to only allow certain characters ***
		$('.alpha').bind('keypress', function (event) {
			var key = !event.charCode ? event.which : event.charCode;
			if ((key >=65 && key <= 90) // UPPER letters
			|| (key >=97 && key <= 122) // lower letters
			|| (key >=48 && key <= 57) // digits
			|| key == 0 // CTRL+F5
			|| key == 8 // backspace
			|| key == 27 // escape
			|| key == 32 // Space
			|| key == 45 // Dash
			|| key == 46 // period
			|| key == 95 // Underscore
			|| key == 99 // CTRL+c
			|| key == 118 // CTRL+v
			|| key == 120 // CTRL+x
			) {}else{
			 event.preventDefault();
			   return false;
			}
		});
		
		
		
	// *** Function to check or uncheck all checkboxes ***
	$(function () { 
		$('.checkall').click(function () {
			$("form input:checkbox").attr('checked', this.checked);
			 var $b = $('input[type=checkbox]');
		});
	});
	
		<cfif id eq '2003'><cfset fName = "WHERE-TD_ATTUID"><cfset fName2 = "WHERE-DBASUPPORT_TEAM_NAME"><cfelse><cfset fName2 = "WHERE-DBA_SUPPORT_TEAM"><cfset fName = "WHERE-DBA_SUPPORT_TEAM_TD_ATTUID"></cfif>
		
	// *** Function to get breadcrumb remember fields logic ***
	$(function () {
		<cfif StructKeyExists(attributes,"WHERE-DBASUPPORT_ORG")>	<!--- below cfif code is used to get user previously selected value for dba team manager start --->	
			<cfif attributes["WHERE-DBASUPPORT_ORG"] EQ "None">				
				<cfif StructKeyExists(attributes,fName)>
					<cfif attributes[fName] NEQ "">
					var TEAM_TD_ATTUID = "<cfoutput>#attributes[fName]#</cfoutput>";
					</cfif>
				</cfif>
				$('##searching').dialog('open');
				$.ajax({
					cache: false,
					type: 'post',
					dataType: "json",
					url: '#myself##xfa.loadTeam#' + "&org=" + $('##WHERE-DBASUPPORT_ORG').val() 
					<cfif StructKeyExists(attributes,fName)>
					<cfif attributes[fName] NEQ "">
					+ "&TD_ATTUID=" + TEAM_TD_ATTUID
					</cfif></cfif>,
					success: function(msg) {
						if (msg.ERROR == '0') {
							//redirect to display page								
							$('###fName#').html(msg.TDOPTIONS);
							$('###fName2#').html(msg.TEAMOPTIONS);
							<cfif StructKeyExists(attributes,fName)>
								<cfif attributes[fName] NEQ "">
								$("select[name='#fName#']").find("option[value='#attributes[fName]#']").attr("selected",true);
								</cfif>
							</cfif>							
							<cfif StructKeyExists(attributes,fName2)>
								<cfif attributes[fName2] NEQ "">
								$("select[name='#fName2#']").find("option[value='#attributes[fName2]#']").attr("selected",true);
								</cfif>
							</cfif>							
							$('##searching').dialog('close');
						} else if (msg.ERROR == '1') {
							alert(msg.MESSAGE);
							$('##searching').dialog('close');
						}
					},
					error: function(msg){alert('There was an error!');
					$('##searching').dialog('close');}
				});	
				
			</cfif>				
		</cfif>	<!--- above cfif code is used to get user previously selected value for dba team manager end --->
		<!--- Below code is for Custom Upickit report --->
		<cfif StructKeyExists(attributes,"EVAL-CI_NAME_INSTANCE") >
			<cfif (attributes["EVAL-CI_NAME_INSTANCE"] eq "List") >
			
			  	 var inputElement = "EVAL-CI_NAME_INSTANCE";
				 var text_id = 'WHERE-'+inputElement.substring(5);
				
								$('##Div'+text_id).html("<textarea name='"+text_id+"' id='"+text_id+"' maxlength='4000' style='width: 174px;                                  height: 70px;' onKeyup='charlim(this);' placeholder= 'Multiple exact values allowed in this field (no wild card)' 	             		  onChange='$(this).val(jQuery.trim($(this).val()));'><cfoutput>#LCase(attributes["WHERE-CI_NAME_INSTANCE"])#</cfoutput></textarea>");
								$('##'+text_id).charCounter(4000);
					
			</cfif>
		</cfif>
		
		<cfif StructKeyExists(attributes,"EVAL-MOTS_ID")>
			<cfif (attributes["EVAL-MOTS_ID"] eq "List") >
			  	 var inputElement = "EVAL-MOTS_ID";
				 var text2_id = 'WHERE-'+inputElement.substring(5);
				
								$('##Div'+text2_id).html("<textarea name='"+text2_id+"' id='"+text2_id+"' maxlength='4000' style='width: 174px;                                  height:70px;' onKeyup='charlim(this);' placeholder= 'Multiple exact values allowed in this field (no wild card)' 	             		  onChange='$(this).val(jQuery.trim($(this).val()));'><cfoutput>#LCase(attributes["WHERE-MOTS_ID"])#</cfoutput></textarea>");
								$('##'+text2_id).charCounter(4000);
					
			</cfif>
		</cfif>
		<cfif StructKeyExists(attributes,"EVAL-PHYSICAL_SERVER_NAME")>
			<cfif (attributes["EVAL-PHYSICAL_SERVER_NAME"] eq "List")>
			  	 var inputElement = "EVAL-PHYSICAL_SERVER_NAME";
				 var text3_id = 'WHERE-'+inputElement.substring(5);
				
								$('##Div'+text3_id).html("<textarea name='"+text3_id+"' id='"+text3_id+"' maxlength='4000' style='width: 174px; 	                                 height:70px;' onKeyup='charlim(this);' placeholder= 'Multiple exact values allowed in this field (no wild card)' 	             		  onChange='$(this).val(jQuery.trim($(this).val()));'><cfoutput>#LCase(attributes["WHERE-PHYSICAL_SERVER_NAME"])#</cfoutput>                               </textarea>");
								$('##'+text3_id).charCounter(4000);
					
			</cfif>
		</cfif>
		
		<!--- Changes for Reuqest #1218234--->
		<cfif StructKeyExists(attributes,"EVAL-VERSION_NUMBER") >
			<cfif (attributes["EVAL-VERSION_NUMBER"] eq "List") >
			
			  	 var inputElement = "EVAL-VERSION_NUMBER";
				 var text4_id = 'WHERE-'+inputElement.substring(5);
				
				$('##Div'+text4_id).html("<textarea name='"+text4_id+"' id='"+text4_id+"' maxlength='4000' style='width: 174px;                                  height: 70px;' onKeyup='charlim(this);' placeholder= 'Multiple exact values allowed in this field (no wild card)' 	             		  onChange='$(this).val(jQuery.trim($(this).val()));'><cfoutput>#LCase(attributes["WHERE-VERSION_NUMBER"])#</cfoutput></textarea>");
				$('##'+text4_id).charCounter(4000);
					
			</cfif>
		</cfif>
		<!--- END Changes for Reuqest #1218234--->
		
		<!--- End of Custom Upickit--->
		(function ($) {
         $.support.placeholder = ('placeholder' in document.createElement('textarea'));
     })(jQuery);

        $(function () {
         if (!$.support.placeholder) {
             $("[placeholder]").focus(function () {
                 if ($(this).val() == $(this).attr("placeholder")) $(this).val("");
             }).blur(function () {
                 if ($(this).val() == "") $(this).val($(this).attr("placeholder"));
             }).blur();

             $("[placeholder]").parents("form").submit(function () {
                 $(this).find('[placeholder]').each(function() {
                     if ($(this).val() == $(this).attr("placeholder")) {
                         $(this).val("");
                     }
                 });
             });
         }
     });
		
		<!--- Changes for Request 1218234--->
		<!---<cfif StructKeyExists(attributes,"WHERE-RDBMS_TYPE")>	<!--- below cfif code is used to get user previously selected value for dba team manager start --->	
			<cfif attributes["WHERE-RDBMS_TYPE"] NEQ "">				
				<cfif StructKeyExists(attributes,"WHERE-VERSION_NUMBER")>
					<cfif attributes["WHERE-VERSION_NUMBER"] NEQ "">
					var VERSION_NUMBER = "<cfoutput>#attributes["WHERE-VERSION_NUMBER"]#</cfoutput>";
					</cfif>
				</cfif>
				$('##searching').dialog('open');
				$.ajax({
					cache: false,
					type: 'post',
					dataType: "json",
					url: '#myself##xfa.loadVerInfo#' + "&type=" + $('##WHERE-RDBMS_TYPE').val()
					<cfif StructKeyExists(attributes,"WHERE-VERSION_NUMBER")>
					<cfif attributes["WHERE-VERSION_NUMBER"] NEQ "">
					+ "&vers=" + VERSION_NUMBER
					</cfif></cfif>,
					success: function(msg) {
						if (msg.ERROR == '0') {
							//redirect to display page								
							$('##WHERE-VERSION_NUMBER').html(msg.VEROPTIONS);
							$("##WHERE-VERSION_NUMBER").multiselect("refresh");
							$('##searching').dialog('close');
						} else if (msg.ERROR == '1') {
							alert(msg.MESSAGE);
							$('##searching').dialog('close');
						}
					},
					error: function(msg){alert('There was an error!');
					$('##searching').dialog('close');}
				});	
				
			</cfif>				
		</cfif>--->	<!--- above cfif code is used to get user previously selected value for dba team manager end --->
		<!--- END of Changes for Request 1218234--->
		
		<!--- used below code for bread crumb back logic start --->
		<cfif StructKeyExists(attributes,fName) or StructKeyExists(attributes,fName2)>
		// PPM - 1584970 Start
		<!--- Code changes (changed '' to 'null') for PPM# 1706936 by RW149D Starts --->
			<cfif StructKeyExists(attributes,fName) eq 'NO'><cfset attributes[fName] ='null'></cfif>
			<cfif StructKeyExists(attributes,fName2) eq 'NO'><cfset attributes[fName2] ='null'></cfif>
		<!--- Code changes (changed '' to 'null') for PPM# 1706936 by RW149D Ends --->
		// PPM - 1584970 End
			<cfif attributes[fName] NEQ "" or  attributes[fName2] NEQ "">		
				<cfif attributes[fName] NEQ "" AND  attributes[fName2] NEQ "">
				urlData = "changed=team&team=" + "<cfoutput>#attributes[fName2]#</cfoutput>" + "&td=" + "<cfoutput>#attributes[fName]#</cfoutput>"
					//urlData = "team=" + "<cfoutput>#attributes[fName2]#</cfoutput>"
					<cfif StructKeyExists(attributes,"WHERE-PRIMARY_ATTUID") or StructKeyExists(attributes,"WHERE-BACKUP_ATTUID")>						
						<cfif StructKeyExists(attributes,"WHERE-PRIMARY_ATTUID") AND attributes["WHERE-PRIMARY_ATTUID"] NEQ "">
							+ "&prim=" + "<cfoutput>#attributes["WHERE-PRIMARY_ATTUID"]#</cfoutput>"
						</cfif>
						<cfif StructKeyExists(attributes,"WHERE-BACKUP_ATTUID") AND attributes["WHERE-BACKUP_ATTUID"] NEQ "">
							+ "&backup=" + "<cfoutput>#attributes["WHERE-BACKUP_ATTUID"]#</cfoutput>"
						</cfif>
					</cfif>;
					
				<cfelseif attributes[fName] NEQ "" AND  attributes[fName2] EQ "">
				urlData = "changed=td&team=<cfoutput>#attributes[fName2]#</cfoutput>&td=<cfoutput>#attributes[fName]#</cfoutput>"
					//urlData = "td=" + "<cfoutput>#attributes[fName]#</cfoutput>"
					<cfif StructKeyExists(attributes,"WHERE-PRIMARY_ATTUID") or StructKeyExists(attributes,"WHERE-BACKUP_ATTUID")>						
						<cfif StructKeyExists(attributes,"WHERE-PRIMARY_ATTUID") AND attributes["WHERE-PRIMARY_ATTUID"] NEQ "">
							+ "&prim=<cfoutput>#attributes["WHERE-PRIMARY_ATTUID"]#</cfoutput>"
						</cfif>
						<cfif StructKeyExists(attributes,"WHERE-BACKUP_ATTUID") AND attributes["WHERE-BACKUP_ATTUID"] NEQ "">
							+ "&backup=<cfoutput>#attributes["WHERE-BACKUP_ATTUID"]#</cfoutput>"
						</cfif>
					</cfif>;
					
				<cfelseif attributes[fName] EQ "" AND  attributes[fName2] NEQ "">
				urlData = "changed=team&team=<cfoutput>#attributes[fName2]#</cfoutput>&td=<cfoutput>#attributes[fName]#</cfoutput>"
					//urlData = "team=" + "<cfoutput>#attributes[fName2]#</cfoutput>"
					<cfif StructKeyExists(attributes,"WHERE-PRIMARY_ATTUID") or StructKeyExists(attributes,"WHERE-BACKUP_ATTUID")>						
						<cfif StructKeyExists(attributes,"WHERE-PRIMARY_ATTUID") AND attributes["WHERE-PRIMARY_ATTUID"] NEQ "">
							+ "&prim=<cfoutput>#attributes["WHERE-PRIMARY_ATTUID"]#</cfoutput>"
						</cfif>
						<cfif StructKeyExists(attributes,"WHERE-BACKUP_ATTUID") AND attributes["WHERE-BACKUP_ATTUID"] NEQ "">
							+ "&backup=" + "<cfoutput>#attributes["WHERE-BACKUP_ATTUID"]#</cfoutput>"
						</cfif>
					</cfif>;				
				</cfif>	
				$('##searching').dialog('open');
				$.ajax({
				cache: false,
				type: 'post',
				dataType: "json",
				url: '#myself##xfa.loadDBAs#' + "&" + urlData,
				success: function(msg) {
					if (msg.ERROR == '0') {
						//If fields exist, populate the drop downs
						if ($("##WHERE-PRIMARY_ATTUID").length > 0){
							$('##field-WHERE-PRIMARY_ATTUID').html(msg.PRIOPTIONS);												
							$("##WHERE-PRIMARY_ATTUID").multiselect({selectedText: "## of ## selected"});							
							//$("##WHERE-PRIMARY_ATTUID").multiselect("refresh");
						}
						if ($("##WHERE-BACKUP_ATTUID").length > 0){
							$('##field-WHERE-BACKUP_ATTUID').html(msg.BACKOPTIONS);
							$("##WHERE-BACKUP_ATTUID").multiselect({selectedText: "## of ## selected"});
							//$("##WHERE-BACKUP_ATTUID").multiselect("refresh");
						}
						//If Team or TD options are returned, set drop down
						if (msg.TDOPTIONS != '') {$('###fName#').html(msg.TDOPTIONS);}
						if (msg.TEAMOPTIONS != '') {$('###fName2#').html(msg.TEAMOPTIONS);}

						$('##searching').dialog('close');
					} else if (msg.ERROR == '1') {
					//	alert(msg.MESSAGE);
						$('##searching').dialog('close');
					}
				i},
				error: function(msg){alert('There was an error!');
				$('##searching').dialog('close');}
			});
		</cfif>	
	  </cfif>
	  <!--- used below code for bread crumb back logic end --->
	
	});
	
	
	// *** Function load Team Managers and Team Name ***
	$(function () { 
		$('##WHERE-DBASUPPORT_ORG').change(function () {
		// If the field is blank, exit;
		if ($('##WHERE-DBASUPPORT_ORG').val() == '') {return false;}
			
		$('##searching').dialog('open');
			$.ajax({
				cache: false,
				type: 'post',
				dataType: "json",
				url: '#myself##xfa.loadTeam#' + "&org=" + $('##WHERE-DBASUPPORT_ORG').val(),
				success: function(msg) {
					if (msg.ERROR == '0') {
						//redirect to display page
							$('###fName#').html(msg.TDOPTIONS);
							$('###fName2#').html(msg.TEAMOPTIONS);
						//PPM - 1571562 Start	
							$("###fName#").multiselect("refresh");
							$("###fName2#").multiselect("refresh");
						//PPM - 1571562 End
						$('##searching').dialog('close');
					} else if (msg.ERROR == '1') {
						alert(msg.MESSAGE);
						$('##searching').dialog('close');
					}
				},
				error: function(msg){alert('There was an error!');
				$('##searching').dialog('close');}
			});
		});	
	});
	
<!--- Changes for Reuqest #1218234--->
	// *** Function load Version Numbers ***
	//$(function () { 
		//$('##WHERE-RDBMS_TYPE').change(function () {
		// If the field is blank, exit;
		//if ($('##WHERE-RDBMS_TYPE').val() == '') {return false;}
			
		//$('##searching').dialog('open');
			//$.ajax({
			//	cache: false,
			//	type: 'post',
			//	dataType: "json",
			//	url: '#myself##xfa.loadVerInfo#' + "&type=" + $('##WHERE-RDBMS_TYPE').val(),
				//success: function(msg) {
					//if (msg.ERROR == '0') {
						//redirect to display page
						//alert($('##WHERE-VERSION_NUMBER').html());
							//$('##WHERE-VERSION_NUMBER').html(msg.VEROPTIONS);
							//$("##WHERE-VERSION_NUMBER").multiselect({selectedText: "## of ## selected"});
							//$("##WHERE-VERSION_NUMBER").multiselect("refresh");
						//$('##searching').dialog('close');
					//} else if (msg.ERROR == '1') {
						//alert(msg.MESSAGE);
						//$('##searching').dialog('close');
					//}
				//},
				//error: function(msg){alert('There was an error!');
				//$('##searching').dialog('close');}
			//});
		//});	
	//});
<!--- END Changes for Reuqest #1218234--->

	// *** Function load Primary DBA and Backup DBA ***
	$(function () { 
		<cfif attributes.id EQ 2003 >
		$('##WHERE-TD_ATTUID, ##WHERE-DBASUPPORT_TEAM_NAME').change(function () {
			var urlData = '';
			if($(this).attr("id") == 'WHERE-TD_ATTUID')
			{
				if ($(this).val() == '') {
				return false;
				} else {
				// Determine which field change to know what the pass
				if ($(this).attr("id") == '#fName#'){urlData = "changed=td";}
				else{urlData = "changed=team";}
				urlData = urlData + "&team=" + $('###fName2#').val() + "&td=" + $('###fName#').val();
				}		
			}
			else
			{
				// Determine which field change to know what the pass
				if ($(this).attr("id") == '#fName#'){urlData = "changed=td";}
				else{urlData = "changed=team";}
				urlData = urlData + "&team=" + $('###fName2#').val() + "&td=" + $('###fName#').val();
			}
		<cfelse>
			$('##WHERE-DBA_SUPPORT_TEAM_TD_ATTUID, ##WHERE-DBA_SUPPORT_TEAM,##WHERE-TD_ATTUID, ##WHERE-DBASUPPORT_TEAM_NAME').change(function () {
		// If the field is blank, exit;
		var urlData = '';
		if ($(this).val() == '') {
			return false;
		} else {
			// Determine which field change to know what the pass
			if ($(this).attr("id") == '#fName#'){urlData = "changed=td";}
			else{urlData = "changed=team";}
			urlData = urlData + "&team=" + $('###fName2#').val() + "&td=" + $('###fName#').val();
		}
		</cfif>
		
		$('##searching').dialog('open');
			$.ajax({
				cache: false,
				type: 'post',
				dataType: "json",
				url: '#myself##xfa.loadDBAs#' + "&" + urlData,
				success: function(msg) {
					if (msg.ERROR == '0') {
						//If fields exist, populate the drop downs
						if ($("##WHERE-PRIMARY_ATTUID").length > 0){
							$('##field-WHERE-PRIMARY_ATTUID').html(msg.PRIOPTIONS);
							$("##WHERE-PRIMARY_ATTUID").multiselect({selectedText: "## of ## selected"});
							//$("##WHERE-PRIMARY_ATTUID").multiselect("refresh");
						}
						if ($("##WHERE-BACKUP_ATTUID").length > 0){
							$('##field-WHERE-BACKUP_ATTUID').html(msg.BACKOPTIONS);
							$("##WHERE-BACKUP_ATTUID").multiselect({selectedText: "## of ## selected"});
							//$("##WHERE-BACKUP_ATTUID").multiselect("refresh");
						}
						//If Team or TD options are returned, set drop down
						/*if (msg.TDOPTIONS != '') {
							$('###fName#').html(msg.TDOPTIONS);
							$("###fName#").multiselect("refresh");
						}*/
						
						if (msg.TEAMOPTIONS != '') {
							$('###fName2#').html(msg.TEAMOPTIONS);
							$("###fName2#").multiselect("refresh");
						}									
						
							
						$('##searching').dialog('close');
					} else if (msg.ERROR == '1') {
					//	alert(msg.MESSAGE);
						$('##searching').dialog('close');
					}
				},
				error: function(msg){alert('There was an error!');
				$('##searching').dialog('close');}
			});
		});		
	});
	
	});
	
	function showDescript(lblid)
		{
			var labelid = lblid;
			var dialogDiv = $("##lblDescript");
			<cfif id eq '2008'>
				dialogDiv.html(lblid).dialog("open");
			<cfelse>
			 //$('##lblDescript').dialog('open');
				$.ajax({
				type: "GET", 
				url: "<cfoutput>#myself##xfa.dspLblDescript#</cfoutput>", 
				cache: false,
				//dataType: "json",
				data: "labelid=" + labelid,
				success: function(msg) {			
					dialogDiv.html(msg).dialog("open");
					//$('##lblDescript').dialog('open');
				}			

			 });
			 </cfif>
			
		}	
</script>
<script type="text/javascript">
function showActDescript(act_desc)
		{
		var labelid = act_desc;
			var dialogDiv = $("##lblDescript");
			dialogDiv.html(act_desc).dialog("open");
		}
</script>
<div id="multi-dialog-confirm">
	<p>Are you sure to Reload the form?<br/>
	You will lose all your previous data.<br/>
	Click <b>Reload</b> to reload form .<br/>
	Click <b>Cancel</b> to keep previously selected data.</p>
</div>
<script type="text/javascript">
$(function () { 
	$('##multi-dialog-confirm').dialog({
    autoOpen: false,
    height: 220,
    width: 450,
    modal: true,
    resizable: false,
    title: 'Please Check...',
    buttons: {
        'Reload': function(){        	
        		$('##multi-dialog-confirm').dialog('close');
           		$('##SearchText').html("Reloading Form Back.... ");
				$("##searching").dialog('open');
				<!--- <cfif StructKeyExists(attributes,"ID")> --->
				var id=$('##A0').val();
				$.ajax({
				cache: false,
				//dataType: "json",
				type: 'post',
				url: '<cfoutput>#myself##xfa.loadForm#</cfoutput>',
				data: 'id=' + id,
				success: function(msg) {$('##searchForm').html(msg);$('##multi-dialog-confirm').dialog().dialog('close');$("##searching").dialog('close');},
				error: function(msg){alert('There was an error');$('##multi-dialog-confirm').dialog('close');$("##searching").dialog('close');}
				});
				<!--- </cfif> --->
        },
        'Cancel': function(){
            $(this).dialog('close');
            return false;
        }
    }
	});	

});	

</script>

<!---Functions for Custom Upickit- HPPM #1164665(formid : 2005)  by Mohammad Abul Aas(am353e)---->
<!--- Changes for request 1218234 for report 2005--->
 <cfif attributes.id EQ 2005 > 
     <style>
	 .txtbxlist{
		outline: none !important;
		border:1px solid red;
		 
	  }
	  .expbx{
		outline: none !important;
		border:1px solid red;
		 
	  }
	  .limitboxWHERE-CI_NAME_INSTANCE {
        clear: both;
        float: left;
     }
	   .limitboxWHERE-MOTS_ID {
        clear: both;
        float: left;
     }
	 
	 .limitboxWHERE-PHYSICAL_SERVER_NAME{
        clear: both;
        float: left;
     }
	  ##lblWHERE-CI_NAME_INSTANCE {
        color: Red;
    	display: inline-block;
     }
	   ##lblWHERE-MOTS_ID {
        color: Red;
    	display: inline-block;
     }
	 
	 ##lblWHERE-PHYSICAL_SERVER_NAME{
        color: Red;
    	display: inline-block;
     }
	  ##msgWHERE-CI_NAME_INSTANCE {
        color: Red;
    	display: inline-block;
     }
	   ##msgWHERE-MOTS_ID {
        color: Red;
    	display: inline-block;
     }
	 
	 ##msgWHERE-PHYSICAL_SERVER_NAME{
        color: Red;
    	display: inline-block;
     }
	 
	 .limitboxWHERE-VERSION_NUMBER{
        clear: both;
        float: left;
     }
	  ##lblWHERE-VERSION_NUMBER{
        color: Red;
    	display: inline-block;
     }
	 
	 ##msgWHERE-VERSION_NUMBER{
        color: Red;
    	display: inline-block;
     }
	 </style>
<!--- END Changes for Reuqest #1218234--->
     
<script type="text/javascript">

			function text2textarea(itemid,text_id,fLen,fmask) 
				{
					var element = document.getElementById(itemid.id);
					var eVal=element.value;
					var text3 = '';
					
					if ( text_id =='WHERE-CI_NAME_INSTANCE')
						{
							text3 = 'CI Name';
						}
					else if ( text_id =='WHERE-PHYSICAL_SERVER_NAME')
						{
							text3 = 'Server';
						}
					else if ( text_id =='WHERE-VERSION_NUMBER') <!--- Changes for Reuqest #1218234--->
						{
							text3 = 'VERSION_NUMBER';
						}
					else 
						{
							text3 = 'Mots';
						}
					
						if (eVal == 'List')
						{
	
	  						$('##Div'+text_id).html("<textarea name='"+text_id+"' id='"+text_id+"' maxlength='4000' style='width: 174px; height: 	                              70px;' onKeyup='charlim(this);' placeholder= 'Multiple exact values allowed in this field (no wild card)' 	             		  onChange='$(this).val(jQuery.trim($(this).val()));'></textarea>");
 							$('##'+text_id).charCounter(4000);
				
				
	/* ---Start-- Placeholder for IE 11 Enterprise mode */
				
		(function ($) {
         $.support.placeholder = ('placeholder' in document.createElement('textarea'));
     })(jQuery);

        $(function () {
         if (!$.support.placeholder) {
             $("[placeholder]").focus(function () {
                 if ($(this).val() == $(this).attr("placeholder")) $(this).val("");
             }).blur(function () {
                 if ($(this).val() == "") $(this).val($(this).attr("placeholder"));
             }).blur();

             $("[placeholder]").parents("form").submit(function () {
                 $(this).find('[placeholder]').each(function() {
                     if ($(this).val() == $(this).attr("placeholder")) {
                         $(this).val("");
                     }
                 });
             });
         }
     });
			
			/* --End -- Placeholder for IE 11 Enterprise mode */	
					}
						else
						{
								$('##Div'+text_id).html('<input id='+text_id+' class="alpha" type="text" name='+text_id+'                    		                                 maxlength='+fLen+' size="25" onChange="$(this).val(jQuery.trim($(this).val()));"></input>');	
								 
								$('##'+text_id).keyup(function () {
                                var searchBox = $(this); 
                                var criteria = searchBox.val();
                                var resultsContainer = $('##'+text_id+ '-search_div');
								
								var search_request = searchBox.data('request_object');
                                
                                //If a search is currently running, stop it before starting a new search
                                if(search_request != null)
								{
									search_request.abort();
								}
								
    							if(text_id == 'WHERE-PHYSICAL_SERVER_NAME' || text_id == 'WHERE-MOTS_ID')
								{
									if(criteria.length <= 1)
									{
									resultsContainer.html('');
									resultsContainer.hide();
									return;
									}
									
									searchBox.data('request_object', $.ajax({
                                    type: 'get',
                                    url: '<cfoutput>#myself##xfa.qryDoDPerson#</cfoutput>',
                                    /*Start -- Request 1027104 -- passing additional data 'Id'*/
									data: 'q=' + encodeURIComponent(criteria) + '&f=' + $(this).attr('id') + '&m='+fmask + '&id=' + #id#,
									
                                    /*End -- Request 1027104 -- passing additional data 'Id'*/
                                    beforeSend: function(){resultsContainer.show();resultsContainer.html('Please Wait... (Continue Typing to Refine Search).');},
                                    success: function(data,status,xhr){
                                        searchBox.data('request_object',null);
                                        resultsContainer.html(data);
                                    },	
                                    error: function(request, err, errorThrown){
                                        request.abort();
                                        searchBox.data('request_object', null);
                                    }
                                }));
								
								}
								<!--- Changes for Reuqest #1218234 --->
								else if (text_id == 'WHERE-VERSION_NUMBER')
								{
									if(criteria.length <= 3)
									{
										resultsContainer.html('');
										resultsContainer.hide();
										return;
									}
									searchBox.data('request_object', $.ajax({
                                    type: 'get',
                                    url: '<cfoutput>#myself##xfa.qryDoDPerson#</cfoutput>',
									data: 'q=' + encodeURIComponent(criteria) + '&f=' + $(this).attr('id') + '&m='+fmask,
									
                                    beforeSend: function(){resultsContainer.show();resultsContainer.html('Please Wait... (Continue Typing to Refine Search).');},
                                    success: function(data,status,xhr){
                                        searchBox.data('request_object',null);
                                        resultsContainer.html(data);
                                    },	
                                    error: function(request, err, errorThrown){
                                        request.abort();
                                        searchBox.data('request_object', null);
                                    }
                                }));
								}
								<!--- END Changes for Reuqest #1218234 --->
								else if(text_id == 'WHERE-CI_NAME_INSTANCE' )
								{
									
									if(criteria.length <= 3)
									{	
									resultsContainer.html('');
									resultsContainer.hide();
									return;
									}
									searchBox.data('request_object', $.ajax({
                                    type: 'get',
                                    url: '<cfoutput>#myself##xfa.qryDoDPerson#</cfoutput>',
                                    /*Start -- Request 1027104 -- passing additional data 'Id'*/
									 data: 'q=' + encodeURIComponent(criteria) + '&f=' + $(this).attr('id') + '&m=CI_NAME_INSTANCE'+ '&id=' + #id#,
									/*End -- Request 1027104 -- passing additional data 'Id'*/
                                    beforeSend: function(){resultsContainer.show();resultsContainer.html('Please Wait... (Continue Typing to Refine Search).');},
                                    success: function(data,status,xhr){
                                        searchBox.data('request_object',null);
                                        resultsContainer.html(data);
                                    },	
                                    error: function(request, err, errorThrown){
                                        request.abort();
                                        searchBox.data('request_object', null);
                                    }
                                }));
								}
								
                            });
	                    }
	
				}
				
				
			function charlim(elementid) 
			{
				var element = document.getElementById(elementid.id);
				var itmID = element.id;
				//var elmVal =element.value; 			
				var regVal = /^[a-zA-Z0-9 ,;._\r\n-]+$/
				var regformots = /^[a-zA-Z0-9 ,;\r\n]+$/
				var tval = $('##'+itmID).val();
				var tlength = tval.length;
				var set= $('##'+itmID).attr("maxlength");
				/* Validate number of expression*/
				var count = tval.match(/[ ,;\r\n]/igm);	
				count = (count) ? count.length : 0;	
				if (count >=1000)
				{
				$('##'+itmID).addClass('expbx');
				$('##Div'+itmID).append("<label class='cmsg"+itmID+"' id='msg"+itmID+"'></label>");
				$('##msg'+itmID).html('You have reached the maximum number of expressions limit');
				
				}else
				{
					 $('##'+itmID).removeClass('expbx');
					 $('##msg'+itmID).remove();
				}
				/* end of number of Expression validation */
				if(tlength>=set)					
				   $('##'+itmID).addClass('txtbxlist');
				else
					 $('##'+itmID).removeClass('txtbxlist');
					 
				if(tlength>0)
				{
					if (itmID == 'WHERE-MOTS_ID') 
					{
						if (regformots.test(tval) == false) 
						{
						$('##Div'+itmID).append("<label class='error"+itmID+"' id='lbl"+itmID+"'></label>");
						$('##lbl'+itmID).html('Only comma,semicolon,space and line break are  allowed for seperators');
						
						}else 
						{
							$('##lbl'+itmID).remove();
						}
					}
					 
					 
					 else if(regVal.test(tval) == false) 
					 {
						$('##Div'+itmID).append("<label class='error"+itmID+"' id='lbl"+itmID+"'></label>");
						$('##lbl'+itmID).html('Only comma,semicolon,space and line break are  allowed for seperators');
						
					}
					
					else 
					{
						$('##lbl'+itmID).remove();

					}
				}
				
				else
				{
						$('##lbl'+itmID).remove();
				}

		}

</script>    	
</cfif>
<!--- END for Changes for request 1218234 for report 2005--->
<!---End of Upickit Form ID 2005--->

<!--- Changes for reuqest 1218234 for reports 2001,2006,2007 --->
<!--- Add 2011 For New Report "Backup Status Report" --->
<cfif attributes.id EQ 2001 OR attributes.id EQ 2006 OR attributes.id EQ 2007 OR attributes.id EQ 2011>
	<style>
		.limitboxWHERE-VERSION_NUMBER
			{
				clear: both;
				float: left;
			}
		##lblWHERE-VERSION_NUMBER
			{
				color: Red;
				display: inline-block;
			}
		##msgWHERE-VERSION_NUMBER
			{
				color: Red;
				display: inline-block;
			}
	</style>
    
    <script type="text/javascript">
		function text2textarea(itemid,text_id,fLen,fmask) 
			{
				var element = document.getElementById(itemid.id);
				var eVal=element.value;
				var text4 = '';
				if (text_id =='WHERE-VERSION_NUMBER')
					{
						text4 = 'VERSION_NUMBER';
					}
					
				if (eVal == 'List')
					{
						$('##Div'+text_id).html("<textarea name='"+text_id+"' id='"+text_id+"' maxlength='4000' style='width: 174px; height:70px;' onKeyup='charlim(this);' placeholder= 'Multiple exact values allowed in this field (no wild card)' onChange='$(this).val(jQuery.trim($(this).val()));'></textarea>");
						$('##'+text_id).charCounter(4000);
						
/* ---Start-- Placeholder for IE 11 Enterprise mode */
				
		(function ($) {
         $.support.placeholder = ('placeholder' in document.createElement('textarea'));
     })(jQuery);

        $(function () {
         if (!$.support.placeholder) {
             $("[placeholder]").focus(function () {
                 if ($(this).val() == $(this).attr("placeholder")) $(this).val("");
             }).blur(function () {
                 if ($(this).val() == "") $(this).val($(this).attr("placeholder"));
             }).blur();

             $("[placeholder]").parents("form").submit(function () {
                 $(this).find('[placeholder]').each(function() {
                     if ($(this).val() == $(this).attr("placeholder")) {
                         $(this).val("");
                     }
                 });
             });
         }
     });
			
/* --End -- Placeholder for IE 11 Enterprise mode */	
						
					}
						
				else
					{	
						$('##Div'+text_id).html('<input id='+text_id+' class="alpha" type="text" name='+text_id+' maxlength='+fLen+' size="25" onChange="$(this).val(jQuery.trim($(this).val()));"></input>');	
								 
						$('##'+text_id).keyup(function () {
						var searchBox = $(this); 
						var criteria = searchBox.val();
						var resultsContainer = $('##'+text_id+ '-search_div');
						
						var search_request = searchBox.data('request_object');
                                
						//If a search is currently running, stop it before starting a new search
						if(search_request != null)
						{
							search_request.abort();
						}
						
						if (text_id == 'WHERE-VERSION_NUMBER')
						{
							if(criteria.length <= 3)
							{
								resultsContainer.html('');
								resultsContainer.hide();
								return;
							}
							searchBox.data('request_object', $.ajax({
							type: 'get',
							url: '<cfoutput>#myself##xfa.qryDoDPerson#</cfoutput>',
							data: 'q=' + encodeURIComponent(criteria) + '&f=' + $(this).attr('id') + '&m='+fmask,
							
							beforeSend: function(){resultsContainer.show();resultsContainer.html('Please Wait... (Continue Typing to Refine Search).');},
							success: function(data,status,xhr){
								searchBox.data('request_object',null);
								resultsContainer.html(data);
							},	
							error: function(request, err, errorThrown){
								request.abort();
								searchBox.data('request_object', null);
							}
						 }));
						}
						
					});
				}
	
				}
				
				function charlim(elementid) 
				{
					var element = document.getElementById(elementid.id);
					var itmID = element.id;
					//var elmVal =element.value; 			
					var regVal = /^[a-zA-Z0-9 ,;._\r\n-]+$/
					var regformots = /^[a-zA-Z0-9 ,;\r\n]+$/
					var tval = $('##'+itmID).val();
					var tlength = tval.length;
					var set= $('##'+itmID).attr("maxlength");
					/* Validate number of expression*/
					var count = tval.match(/[ ,;\r\n]/igm);	
					count = (count) ? count.length : 0;	
					if (count >=1000)
					{
					$('##'+itmID).addClass('expbx');
					$('##Div'+itmID).append("<label class='cmsg"+itmID+"' id='msg"+itmID+"'></label>");
					$('##msg'+itmID).html('You have reached the maximum number of expressions limit');
					
					}else
					{
						 $('##'+itmID).removeClass('expbx');
						 $('##msg'+itmID).remove();
					}
					/* end of number of Expression validation */
					if(tlength>=set)					
					   $('##'+itmID).addClass('txtbxlist');
					else
						 $('##'+itmID).removeClass('txtbxlist');
						 
					if(tlength>0)
					{
						
						 if(regVal.test(tval) == false) 
						 {
							$('##Div'+itmID).append("<label class='error"+itmID+"' id='lbl"+itmID+"'></label>");
							$('##lbl'+itmID).html('Only comma,semicolon,space and line break are  allowed for seperators');
							
						}
						
						else 
						{
							$('##lbl'+itmID).remove();
	
						}
					}
					
					else
					{
						$('##lbl'+itmID).remove();
					}

			}
	</script>
</cfif>
<!--- END for Changes for reuqest 1218234 for reports 2001,2006,2007 --->
	<cfif attributes.id EQ 2002 OR attributes.id EQ 2006 OR attributes.id EQ 2007>
			<script type="text/javascript">
				function check(oform){
					var dialogMessage;					
					if (dialogMessage == null) {dialogMessage = 'Searching...';}	
					//validation starts	for report 2			
						var elements = oform.elements;
						var count = 0;
						var count1 = 0;		   
						  //frm2.reset();		
						  for(j=0; j<elements.length; j++) {		     
						  field_type = elements[j].type.toLowerCase();
						 //alert(field_type);
						  switch(field_type) {						   					    
						    case "select-multiple":
						    	if( elements[j].selectedIndex != -1){
						    		var count = count + 1;
						    		//alert(count);
						    	}						          
						      break;						      
							case "select-one":
								if( elements[j].selectedIndex != 0){
						    		var count1 = count1 + 1;
						    		//alert(count1);
						    	}																				
							break;							
						    default:
						      break;
						  }
						    }
						    		if (count > 0)
									  {
									  	$('##SearchText').html(dialogMessage);
										$('##searching').dialog('open');						
										$("##frm2").submit();
									  }
									else if (count1 > 0)
									  {
										$('##SearchText').html(dialogMessage);
										$('##searching').dialog('open');						
										$("##frm2").submit();
									  }
									else
									  {
									  alert("select at least one field from the form to run your report.");
									  }					   
								//validation ends	for report2    
					}
			</script>
       <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Input Character Restrictions--->              
        <cfelseif attributes.id EQ 2008 >    		
        	<script type="text/javascript">
				function check(oform){
					var dialogMessage;					
					if (dialogMessage == null) {dialogMessage = 'Searching...';}	
					var data = $('##search_item').val();
					if( data == '')
					{
						alert("Please enter the value to run your report.");
						return false;
					}
					else if ( data.length < 3)
					{
						alert("Input value must be at least 3 characters in length.");
						return false;
					}
					 $('##SearchText').html(dialogMessage);
					$('##searching').dialog('open');								
					$("##frm2").submit();
				}
			</script>		
        <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Input Character Restrictions--->
        <cfelseif attributes.id EQ 2009>
        	<script type="text/javascript">		
			
			
				//to see at least one checkbox is checked from output fields	
				
				function check(oform){
						var dialogMessage;					
						if (dialogMessage == null) {dialogMessage = 'Searching...';}				   
							var all_checkboxes = $('##myDiv input[type="checkbox"]');
							
							//validation starts	for report 			
							var elements = oform.elements;
							var count = 0;
							var count1 = 0;
							var count2 = 0;		   
							  //frm2.reset();		
							  for(j=0; j<elements.length; j++) {		     
							  field_type = elements[j].type.toLowerCase();

							  switch(field_type) {								  						   					    
							    case "select-multiple":
							    	if( elements[j].selectedIndex != -1){
							    		var count = count + 1;
							    		//alert(count);
							    	}						          
							      break;						      	
								case "text":	
							  	   if( elements[j].value != "" && elements[j].value.length > 2){
							    		var count1 = count1 + 1;
							    		//alert(count1);
							    	}
									if( elements[j].value == "" ){
							    		var count2 = count2 + 1;
							    	}							       							      
							      break;
							    default:
							      break;
							  }
							    }	//validation ends	for report 
							    					
								if ((all_checkboxes.is(':checked')) && (count>0) && ((count1>0) || (count2 >0)))
								{
									//alert('they are all checked');
									$('##SearchText').html(dialogMessage);
									$('##searching').dialog('open');								
									$("##frm2").submit();
									return true;
								}
								else if ((all_checkboxes.is(':checked')) && (count == 0) && (count1>0)) 
								{
									//alert('they are all checked');
									$('##SearchText').html(dialogMessage);
									$('##searching').dialog('open');								
									$("##frm2").submit();
									return true;
								}
								else if((all_checkboxes.is(':checked')) && (count > 0) && (count1 == 0))
								{
									alert(' Please enter minimum 3 characters in search field.');
									return false;							    
								}
								else if ( (! all_checkboxes.is(':checked')) && ((count > 0) || (count1 > 0)) )
								{
									alert('Please Select At least One Checkbox From Output Fields.');
									return false;
								}
								else
								{
									alert('Please Select At least One Checkbox From Output Fields.\nPlease Select At least One Search Field From Search Criteria.');
									return false;
								}
						} //end of function check
						
							
				
			</script>    	
	

	
            	
        <!--- New report Asset Identification-- HPPPM Request# 1050591 (ak5949)-- Input Character Restrictions---> 
        
        
        
<cfelse>
			<script type="text/javascript">		
			
			
				//to see at least one checkbox is checked from output fields	
				
				function check(oform){
						var dialogMessage;	
                    //    alert(oform);						
						if (dialogMessage == null) {dialogMessage = 'Searching...';}				   
							var all_checkboxes = $('##myDiv input[type="checkbox"]');
							
							//validation starts	for report 			
							var elements = oform.elements;
							var count = 0;
							var count1 = 0;
							var count2 = 0;		   
							  //frm2.reset();		
							  for(j=0; j<elements.length; j++) {		     
							  field_type = elements[j].type.toLowerCase();

							  switch(field_type) {								  						   					    
							    case "select-multiple":
							    	if( elements[j].selectedIndex != -1){
							    		var count = count + 1;
							    		//alert(count);
							    	}						          
							      break;						      
								case "select-one":
									if( elements[j].selectedIndex != 0){
							    		var count1 = count1 + 1;
							    		//alert(count1);
							    	}																				
								  break;	
								case "text":	
							  	   if( elements[j].value != ""){
							    		var count2 = count2 + 1;
							    		//alert(count2);
							    	}							      
							      break;						
							    default:
							      break;
							  }
							    }	//validation ends	for report 
							    					
								if ((all_checkboxes.is(':checked')) && ((count>0) || (count1>0) || (count2>0))) 
								{
							    //alert('they are all checked');
							    $('##SearchText').html(dialogMessage);
								$('##searching').dialog('open');
								if($("##searchfrmId").val() == 2011 && $("input[name='exporttoexcel']:checked").val() == "excel")
								{
									//$('##searching').dialog('close');
									jqBackupReportExcel();
								}
								else
									$("##frm2").submit();
							    return true;
								}
								alert('Please Select At least One Checkbox From Output Fields.\nPlease Select At least One Search Field From Search Criteria.');
								return false;							    
						} //end of function check
						
							
				
			</script>
		</cfif>
</cfoutput>
</cfif>

<script type="text/javascript">	
function jqChangeAction()
	{
		
		if($("#searchfrmId").val() == 2011)
		{
			if($("input[name='exporttoexcel']:checked").val() == "excel")
			{
				$('#frm2').attr('action', '<cfoutput>#myself##xfa.submitexl#</cfoutput>');
				$('#do').val('<cfoutput>#xfa.submitexl#</cfoutput>');
			}
			if($("input[name='exporttoexcel']:checked").val() == "html")
			{
				
				$('#frm2').attr('action', '<cfoutput>#myself##xfa.submit1#</cfoutput>');
				$('#do').val('<cfoutput>#xfa.submit1#</cfoutput>');
			}
		}
	}
	
function jqBackupReportExcel()
	{
		$.ajax({
				cache:false,
				type: "POST",
				url: "<cfoutput>#myself##xfa.submitexl#</cfoutput>",
				data: $("#frm2").serialize(),
				dataType : 'html',
				success: function(response)
				{
					$('#searching').dialog('close');
					if (response.indexOf("No Record Founds") != -1)
					{
						alert('0 Results Returned.');
					}
					else
					{
						if (response.indexOf("Mail Sent") != -1)
						{
							alert('Export Complete and Mail Sent');
						}
						else
						{
							//var vresult1 = $(response).find("input[name='dwnldurl']").val();
							window.open(response);
						}
					}
				},
				error : function(xhr,status,error){
					alert("error:-" + status);
				}
			});
	}
</script>
