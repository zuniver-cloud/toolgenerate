package ${package_name}.action;


<#list tables as t>
    import ${package_name}.dao.I${t.pinyinOfEntityName}Dao;
    import ${package_name}.dao.impl.${t.pinyinOfEntityName}DaoImpl;
    import ${package_name}.entity.${t.pinyinOfEntityName};
</#list>

import ${package_name}.entity.DbColumn;
import ${package_name}.utils.DBUtils;
import com.fy.toolhelper.tool.ActionTool;
import com.fy.toolhelper.util.FormatUtils;
import com.fy.toolhelper.util.RequestUtils;
import com.fy.toolhelper.util.ResponseUtils;

import com.fy.sqlparam.impl.SqlParameter;
import com.fy.sqlparam.param.ISqlParameter;
import com.fy.sqlparam.param.ISqlQuery;

import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.poi.POIXMLException;
import org.apache.poi.xssf.usermodel.XSSFCell;
import org.apache.poi.xssf.usermodel.XSSFRow;
import org.apache.poi.xssf.usermodel.XSSFSheet;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.apache.poi.ss.usermodel.DataFormatter;
import org.apache.poi.ss.usermodel.DateUtil;
import org.springframework.util.StringUtils;

import java.text.NumberFormat;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.sql.Connection;
import java.sql.Date;
import java.sql.Time;
import java.text.ParseException;
import java.io.File;
import java.io.InputStream;
import java.util.*;
import java.util.stream.Collectors;

import java.io.IOException;
import java.sql.SQLException;
import javax.servlet.ServletOutputStream;
import org.apache.poi.ss.usermodel.VerticalAlignment;
import org.apache.poi.xssf.usermodel.XSSFCellStyle;

import javax.script.ScriptEngine;
import javax.script.ScriptEngineManager;
import javax.script.ScriptException;

import static org.apache.poi.ss.usermodel.Cell.CELL_TYPE_NUMERIC;

public class ${tool_class_name}Tool extends ActionTool {

    @Override
    protected boolean onInit(GlobalContext context, String configParamStr) throws Exception {
        return false;
    }

    @Override
    protected String onBeforeAct(HttpServletRequest request, HttpServletResponse response,
        TemporyContext context, String runToolParamStr) throws Exception {
        return RequestUtils.getStringParameter(request, "action");
    }

    @Override
    protected Object onCatchException(Throwable ex) throws Exception {
        return null;
    }

    @Override
    protected void onAfterAct(String action, Object result) throws Exception {

    }

<#if n_view_tool>

<#if isFromDatabase == false>
<#if hasDeleteControl>
<#list tables as t>
    @Action
    public Map<String, Object> delete${t.pinyinOfEntityName}ById(
    HttpServletRequest request,
    HttpServletResponse response) throws Exception {
    Long id = RequestUtils.getLongParameter(request, "id");
    if (id == null) {
    throw new Exception("id参数为空！");
    }
    I${t.pinyinOfEntityName}Dao dao = new ${t.pinyinOfEntityName}DaoImpl();

    Map<String, Object> result = new HashMap<>();
    ${t.pinyinOfEntityName} ${t.pinyinOfEntityName?uncap_first} = new ${t.pinyinOfEntityName}();
    ${t.pinyinOfEntityName?uncap_first}.setId(id);
    if (dao.delete(getConnection(), ${t.pinyinOfEntityName?uncap_first}) > 0) {
    result.put("result", true);
    result.put("msg", "删除成功！");
    } else {
    result.put("result", false);
    result.put("msg", "删除失败！");
    }

    return result;
    }
</#list>
</#if>

<#if hasAdd>
<#list tables as t>
    @Action
    public Map<String, Object> add${t.pinyinOfEntityName}(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

    <#if t.columns??>
        <#list t.columns as c>
            <#if (c.changedName != 'id') >
                <#if (c.type == 'VARCHAR' || c.type == 'TEXT')>
            String ${c.changedName} = RequestUtils.getStringParameter(request, "${c.changedName}");
                <#elseif (c.type == 'INT' || c.type == 'SMALLINT' || c.type == 'TINYINT')>
            Integer ${c.changedName} = RequestUtils.getIntegerParameter(request, "${c.changedName}");
                <#elseif (c.type == 'BIGINT' || c.type == 'NUMERIC' || c.type == 'DECIMAL')>
            Long ${c.changedName} = RequestUtils.getLongParameter(request, "${c.changedName}");
                <#elseif c.type == 'BIT'>
            boolean ${c.changedName} = RequestUtils.getBooleanParameter(request, "${c.changedName}");
                <#elseif c.type == 'TIMESTAMP' || c.type == 'DATE'>
            Date ${c.changedName} = getDateParameter(request, "${c.changedName}", "yyyy-MM-dd");
                <#elseif c.type == 'TIME'>
            Time ${c.changedName} = getTimeParameter(request, "${c.changedName}");
                <#else>
            String ${c.changedName} = RequestUtils.getStringParameter(request, "${c.changedName}");
                </#if>
            </#if>
        </#list>
    </#if>
        I${t.pinyinOfEntityName}Dao dao = new ${t.pinyinOfEntityName}DaoImpl();
        Map<String, Object> result = new HashMap<>();
        ${t.pinyinOfEntityName} ${t.pinyinOfEntityName?uncap_first} = new ${t.pinyinOfEntityName}();

        <#if t.columns??>
            <#list t.columns as c>
                <#if (c.changedName != 'id')>
                ${t.pinyinOfEntityName?uncap_first}.set${c.changedName?cap_first}(${c.changedName});
                </#if>
            </#list>
        </#if>
        try {
            dao.save(getDBConnection(), ${t.pinyinOfEntityName?uncap_first});

            result.put("result", true);
            result.put("msg", "添加成功！");
        } catch (Exception e) {
            result.put("result", false);
            result.put("msg", "添加失败！");
        }
        return result;
    }

</#list>
</#if>

<#if hasUpdateControl>
<#list tables as t>
    @Action
    public Map<String, Object> edit${t.pinyinOfEntityName}ById(
            HttpServletRequest request,
            HttpServletResponse response) throws Exception {

<#if t.columns??>
    <#list t.columns as c>
        <#if (c.changedName == 'id') >
        Long id = RequestUtils.getLongParameter(request, "id");
        <#else>
            <#if (c.type == 'VARCHAR' || c.type == 'TEXT')>
        String ${c.changedName} = RequestUtils.getStringParameter(request, "${c.changedName}");
            <#elseif (c.type == 'INT' || c.type == 'SMALLINT' || c.type == 'TINYINT')>
        Integer ${c.changedName} = RequestUtils.getIntegerParameter(request, "${c.changedName}");
            <#elseif (c.type == 'BIGINT' || c.type == 'NUMERIC' || c.type == 'DECIMAL')>
        Long ${c.changedName} = RequestUtils.getLongParameter(request, "${c.changedName}");
            <#elseif c.type == 'BIT'>
        boolean ${c.changedName} = RequestUtils.getBooleanParameter(request, "${c.changedName}");
            <#elseif c.type == 'TIMESTAMP' || c.type == 'DATE'>
        Date ${c.changedName} = getDateParameter(request, "${c.changedName}", "yyyy-MM-dd");
            <#elseif c.type == 'TIME'>
        Time ${c.changedName} = getTimeParameter(request, "${c.changedName}");
            <#else>
        String ${c.changedName} = RequestUtils.getStringParameter(request, "${c.changedName}");
            </#if>
        </#if>
    </#list>
</#if>
        I${t.pinyinOfEntityName}Dao dao = new ${t.pinyinOfEntityName}DaoImpl();
        Map<String, Object> result = new HashMap<>();
        ${t.pinyinOfEntityName} ${t.pinyinOfEntityName?uncap_first} = new ${t.pinyinOfEntityName}();

<#if t.columns??>
    <#list t.columns as c>
        ${t.pinyinOfEntityName?uncap_first}.set${c.changedName?cap_first}(${c.changedName});
    </#list>
</#if>
        try {
            dao.update(getDBConnection(), ${t.pinyinOfEntityName?uncap_first});

            result.put("result", true);
            result.put("msg", "修改成功！");
        } catch (Exception e) {
            result.put("result", false);
            result.put("msg", "修改失败！");
        }
        return result;
    }
<#--</#if>-->


</#list>
</#if>
</#if>
<#list tables as t>

    @Action
    public Map<String, Object> getPage${t.pinyinOfEntityName}(HttpServletRequest request) throws Exception {
        int page = RequestUtils.getIntegerParameter(request, "page",1);
        int pageSize = RequestUtils.getIntegerParameter(request, "pageSize", 10);
        String key = RequestUtils.getStringParameter(request,"key");
        String scope = RequestUtils.getStringParameter(request, "scope");
    //改动2
        String  classifyButtonValue=RequestUtils.getStringParameter(request,"classifyButtonValue");
    <#list searchList as item>
        String searchKey${item.name}=RequestUtils.getStringParameter(request,"searchKey${item.name}");
    </#list>

        ISqlParameter parameter = new SqlParameter();
        parameter.setPagination(page, pageSize, 0);
    //旧代码，可以不用这个判断
<#--        if (!StringUtils.isEmpty(key)){-->
<#--            if (!StringUtils.isEmpty(scope)) {-->
<#--                switch (scope) {-->
<#--                    case "all":-->
<#--        <#if t.columns??>-->
<#--            <#list t.columns as c>-->
<#--                <#if c.name != 'id'>-->
<#--                    <#if (c?index == 1)>-->
<#--                        ISqlQuery query = parameter.query(SqlParameter.Query.to("${c.changedName}").like("%" + key.trim() + "%"));-->
<#--                    <#else>-->
<#--                        query.or(SqlParameter.Query.to("${c.changedName}").like("%" + key.trim() + "%"));-->
<#--                    </#if>-->
<#--                </#if>-->
<#--            </#list>-->
<#--        </#if>-->
<#--                        break;-->
<#--        <#if t.columns??>-->
<#--            <#list t.columns as c>-->
<#--                <#if c.name != 'id'>-->
<#--                    case "${c.changedName}":-->
<#--                        ISqlQuery query${c?index} = parameter.query(SqlParameter.Query.to(scope).like("%" + key.trim() + "%"));-->
<#--                        break;-->
<#--                </#if>-->
<#--            </#list>-->
<#--        </#if>-->
<#--                    }-->
<#--            }-->
<#--        }-->

    //改动2
    //模板里写一个循环查询键值，且要替换为别名
    <#list searchList as item>
        if(searchKey${item.name} != null && !"".equals(searchKey${item.name}.trim())) {
        //新方法
        parameter.query(SqlParameter.Query.to("${item.name}").like("%"+searchKey${item.name}.trim()+"%"));
<#--        //旧方法：这一步替换别名-->
<#--        <#list t.columns as c>-->
<#--            <#if c.comment == item.name>-->
<#--                parameter.query(SqlParameter.Query.to("${c.changedName}").like("%"+searchKey${item.name}.trim()+"%"));-->
<#--            </#if>-->
<#--        </#list>-->
        }
    </#list>
<#--    //查询所有-->
<#--    <#if t.columns??>-->
<#--        <#list t.columns as c>-->
<#--            <#if c.name != 'id'>-->
<#--                <#if (c?index == 1)>-->
<#--                    ISqlQuery query = parameter.query(SqlParameter.Query.to("${c.changedName}").like("%" + searchKey${item.name}.trim() + "%"));-->
<#--                <#else>-->
<#--                    query.or(SqlParameter.Query.to("${c.changedName}").like("%" + searchKey${item.name}.trim() + "%"));-->
<#--                </#if>-->
<#--            </#if>-->
<#--        </#list>-->
<#--    </#if>-->
    //按照字段值分类
    if (classifyButtonValue!= null && !"".equals(classifyButtonValue.trim())) {
    //这一行在模板解析时需要传入一个参数，classifyKey，但是这是真实的列名，数据库里面替换了一个别名
    <#if t.columns?? && classifyKey??>
        //新方法
        parameter.query(SqlParameter.Query.to("${classifyKey}").eq(classifyButtonValue));
<#--        //旧方法，需要替换别名-->
<#--        <#list t.columns as c>-->
<#--            <#if c.comment == classifyKey>-->
<#--                parameter.query(SqlParameter.Query.to("${c.changedName}").eq(classifyButtonValue));-->
<#--            </#if>-->
<#--        </#list>-->
    </#if>

    }
        I${t.pinyinOfEntityName}Dao dao = new ${t.pinyinOfEntityName}DaoImpl();
        List<${t.pinyinOfEntityName}> rows = dao.getPage(getConnection(),parameter);
        long total = dao.getPageCount(getConnection(),parameter);

        Map<String, Object> result = new HashMap<>();
        result.put("rows", rows);
        result.put("total", total);
        result.put("totalPage", (int) Math.ceil((double) total / pageSize));

        return result;
    }

</#list>

</#if>

<#if n_view_tool>

 @Action
    public void downloadExcelModel(HttpServletRequest request,HttpServletResponse response) throws SQLException, IOException {
String table = RequestUtils.getStringParameter(request, "table");
String tableName = RequestUtils.getStringParameter(request, "tableName");

List<DbColumn> columns = DBUtils.getColumnsByTableName(getConnection(),table);
<#--<#if columns??>
<#assign formulaindex=0>
<#list columns as c>
    <#if c.name != 'id' && !c.name?starts_with("column")>&lt;#&ndash;说明是公式字段&ndash;&gt;
        columns.remove(${formulaindex}); // 移除公式字段
        <#assign formulaindex&ndash;&gt; &lt;#&ndash;因为移除一个元素后，list会自动变更索引&ndash;&gt;
    </#if>
    <#assign formulaindex++>
</#list>
</#if>-->
<#--        columns.remove(0);  //移除掉id字段-->
    Iterator<DbColumn> iterator = columns.iterator();
        while (iterator.hasNext()) {
        DbColumn column = iterator.next();
        if (column.getName().equals("id")) {
        iterator.remove();
        }
        }
        // 创建工作簿
        XSSFWorkbook wb = new XSSFWorkbook();
        // 创建工作表
        XSSFSheet sheet = getSheet(columns, wb);
        autoWidth(columns, sheet);

        downloadExcelFile("${tool_name}-" + tableName + "-Excel模板",wb,response);
    }


<#list tables as t>
    @Action
    public void downloadExcelData${t.pinyinOfEntityName}(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String tableName = "${t.name}";
        List<DbColumn> columns = DBUtils.getColumnsByTableName(getConnection(), tableName);
        Iterator<DbColumn> iterator = columns.iterator();
        //不显示id
        while (iterator.hasNext()) {
            DbColumn column = iterator.next();
            if (column.getName().equals("id")) {
               iterator.remove();
            }
        }
        // 创建工作簿
        XSSFWorkbook wb = new XSSFWorkbook();
        XSSFSheet sheet = getSheet(columns, wb);

        I${t.pinyinOfEntityName}Dao dao = new ${t.pinyinOfEntityName}DaoImpl();
        List<${t.pinyinOfEntityName}> allData = dao.getAll${t.pinyinOfEntityName}(getConnection());
            for (int i = 0; i < allData.size(); i++) {
                XSSFRow row = sheet.createRow(i + 1);
    <#if t.columns??>
        <#assign formulaindex=0>
        <#list t.columns as c>
            <#if (c.changedName != 'id')>
                XSSFCell ${c.name} = row.createCell(${formulaindex});
                ${c.name}.setCellValue(allData.get(i).get${c.changedName?cap_first}());
                <#assign formulaindex++>
            </#if>
        </#list>
    </#if>
            }

        autoWidth(columns, sheet);
        downloadExcelFile("${tool_name}-${t.nameChinese}-数据-" + LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd-hhmm")) , wb, response);
    }

</#list>

    public static void downloadExcelFile(String title, XSSFWorkbook wb,HttpServletResponse response) throws IOException {
        response.reset();

        response.setCharacterEncoding("utf-8");
        response.setContentType("application/vnd.ms-excel;charset=utf-8");
        response.setHeader("Content-Disposition", "attachment;filename="+ new String((title + ".xlsx").getBytes(), "iso-8859-1"));

        try(ServletOutputStream outputStream = response.getOutputStream()) {
            wb.write(outputStream);
            outputStream.flush();
        }catch (Exception e) {
            throw e;
        }
    }

    @Action
    public Map<String, Object> importDataFromExcel( HttpServletRequest request,
                                                    HttpServletResponse response) throws Exception {

        String tableName = RequestUtils.getStringParameter(request, "table");
        FileItem item = getUploadFile("file");
        InputStream inputStream = item.getInputStream();

        XSSFWorkbook wb = null;
        try {
            // 1.转换为Excel XSSFWorkbook
            wb = new XSSFWorkbook(inputStream);
        }catch (POIXMLException e){
            e.printStackTrace();
            return ResponseUtils.asResultAndMsg(false,"解析文件失败，请检查Excel文件是否有误！");
        }

        // 2.对比字段长度
        // 2.1获取Excel Sheet
        XSSFSheet sheet = wb.getSheetAt(0);
        // 总行数
        int rowCount = sheet.getPhysicalNumberOfRows();

        List<DbColumn> columns = DBUtils.getColumnsByTableName(getConnection(),tableName);

<#if columns??>
    <#assign formulaindex=0>
    <#list columns as c>
        <#if c.name != 'id' && !c.name?starts_with("column")><#--说明是公式字段-->
        columns.remove(${formulaindex}); // 移除公式字段
        <#assign formulaindex--> <#--因为移除一个元素后，list会自动变更索引-->
        </#if>
        <#assign formulaindex++>
    </#list>
</#if>
       <#if isFromDatabase == false>
        columns.remove(0);  //移除掉id字段
       </#if>
        DbColumn dbColumn = columns.get(0);

        //查找第一个自定义字段在表格的位置
        int x = 0;
        int y = 0;
        tab:
        for(int i = 0 ; i<rowCount ;i++) {
            XSSFRow row = sheet.getRow(i);
            if (row == null){
                continue ;
            }
            for(int j=0 ; j<row.getPhysicalNumberOfCells() ; j++) {
                XSSFCell cell = row.getCell((short)j);
                if (cell == null) {
                    continue;
                }
                cell.setCellType(XSSFCell.CELL_TYPE_STRING);
                String cellValue = cell.getStringCellValue();
                if (dbColumn.getComment().equals(cellValue)) {
                    y = i;
                    x = j;
                    break tab;
                }
            }
        }

        //检查字段是否匹配

        XSSFRow row1 = sheet.getRow(y);
        StringJoiner excelJoiner = new StringJoiner(", ");
        for (int i = x; i< row1.getPhysicalNumberOfCells(); i++){
            XSSFCell cell = row1.getCell(i);
            cell.setCellType(XSSFCell.CELL_TYPE_STRING);
            excelJoiner.add(cell.getStringCellValue().trim());
        }

        String columnJoin = String.join(", ",columns.stream().map(c->c.getComment().trim()).collect(Collectors.toList()));

        if (!excelJoiner.toString().equals(columnJoin)) {
            return ResponseUtils.asResultAndMsg(false, "<span><strong>字段不匹配,请确保Excel中有这些字段且依次排在同一行表格中：</strong><br>"+columnJoin + "<span>");
        }

        NumberFormat numberFormat = NumberFormat.getNumberInstance();
        //开始导入
        Connection connection = getConnection();
        for(int i = y + 1; i<rowCount ;i++) {
               XSSFRow row = sheet.getRow(i);

               if (row == null){
               continue;
               }
            Map<String, String> values = new HashMap<>();


            for(int j = x, k = 0; j<row.getPhysicalNumberOfCells() ; j++,k++) {
                XSSFCell cell = row.getCell((short)j);
                if (cell == null) {
                    continue;
                }

                String cellvalue;
                if (cell.getCellType() == CELL_TYPE_NUMERIC) {
                    if(DateUtil.isCellDateFormatted(cell)){
                    DataFormatter dataFormatter = new DataFormatter();
                    cellvalue = dataFormatter.formatCellValue(cell);
                    }else{
                        double d = cell.getNumericCellValue();
                        cellvalue = numberFormat.format(d);
                    }
                } else {
                    cell.setCellType(XSSFCell.CELL_TYPE_STRING);
                    cellvalue = cell.getStringCellValue();
                }

                values.put(columns.get(k).getName(),cellvalue);
        }
<#if columns??>
    <#list columns as c>
        <#if c.name != 'id' && !c.name?starts_with("column")>
            // 添加公式值
            String formulaValue = resolveFormulaValue("${c.comment}",values);
            values.put("${c.name}", formulaValue);
        </#if>
    </#list>
</#if>
        String sql = DBUtils.generateAddSQL(tableName, values);
        System.out.println(sql);

            connection.prepareStatement(sql).execute();
        }

        return ResponseUtils.asResultAndMsg(true,"导入成功");
        }

        // 使用js引擎来执行代码
    private String resolveFormulaValue(String s, Map<String, String> values) throws ScriptException {
        // 替换公式s中的变量a1,a2...
        Set<String> columnNames = values.keySet();
        int flag = 1;
        for (String columnName :
                columnNames) {
            // 获取字段值
            String columnValue = values.get(columnName);
            s = s.replaceAll("a"+flag, columnValue); // 首先替换所有的a1，然后是替换所有的a2，依次下去
            flag++;
        }
        ScriptEngineManager scriptEngineManager = new ScriptEngineManager();
        ScriptEngine js = scriptEngineManager.getEngineByName("js");
        try{
            Object eval = js.eval(s);
            System.out.println(eval);
            return String.valueOf(eval);
        } catch (ScriptException e) {
            return "出错！error";
        }
    }
</#if>



    private void autoWidth(List<DbColumn> columns, XSSFSheet sheet) {
        // 自动调整宽度
        for (int i = 0; i < columns.size(); i++) {
            sheet.autoSizeColumn(i);
            sheet.setColumnWidth(i, sheet.getColumnWidth(i)*17/10);
        }
    }

    private XSSFSheet getSheet(List<DbColumn> columns, XSSFWorkbook wb) {
        // 创建工作表
        XSSFSheet sheet = wb.createSheet("Sheet1");

        // 1.输出列头
        XSSFRow columnRow = sheet.createRow(0);
        columnRow.setHeight((short) 500);

        // 输出单元格(第一列)
        XSSFCellStyle style = wb.createCellStyle();
        style.setAlignment(XSSFCellStyle.ALIGN_CENTER);
        style.setVerticalAlignment(VerticalAlignment.CENTER);
        for (int i = 0; i < columns.size(); i++) {
            XSSFCell cell = columnRow.createCell((short) i);
            cell.setCellType(XSSFCell.CELL_TYPE_STRING);
            cell.setCellValue(columns.get(i).getComment());
<#--            cell.setCellValue(columns.get(i).getName());-->
            cell.setCellStyle(style);
        }

        return sheet;
    }

    Date getDateParameter(HttpServletRequest request, String name, String format) {
        String temp = request.getParameter(name);
        if(temp != null && !temp.trim().isEmpty()){
            try {
                java.util.Date date = FormatUtils.string2Date(temp, format);
                return new Date(date.getTime());
            } catch (ParseException e) {
                e.printStackTrace();
            }
        }
        return null;
    }

    Time getTimeParameter(HttpServletRequest request, String name) {
        String temp = request.getParameter(name);
        if(temp != null && !temp.trim().isEmpty()){
            return Time.valueOf(temp);
        }
        return null;
    }
}
