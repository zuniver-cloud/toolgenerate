package com.fy.tool.toolmaker.action;

import com.alibaba.fastjson.JSONObject;
import com.fy.basejar.tool.ActionToolBase;
import com.fy.tool.toolmaker.core.DbColumn;
import com.fy.tool.toolmaker.core.DbTable;
import com.fy.tool.toolmaker.core.ToolConfiguration;
import com.fy.tool.toolmaker.core.ToolMakerUtil;
import com.fy.tool.toolmaker.entity.ToolMakerEntity;
import com.fy.tool.toolmaker.service.CoreRemoteService;
import com.fy.tool.toolmaker.service.IToolMakerService;
import com.fy.tool.toolmaker.service.impl.CoreRemoteServiceImpl;
import com.fy.tool.toolmaker.service.impl.ToolMakerServiceImpl;
import com.fy.tool.toolmaker.dao.IToolMakerDao;
import com.fy.tool.toolmaker.dao.impl.ToolMakerDaoImpl;
import com.fy.tool.toolmaker.vo.*;
import com.fy.tool.toolmaker.util.PinyinUtil;
import com.fy.tool.toolmaker.util.ZipUtil;
import com.fy.toolhelper.util.FileUtils;
import com.fy.toolhelper.util.FormatUtils;
import com.fy.toolhelper.util.RequestUtils;
import com.fy.tre.exception.ErrorCode;
import com.fy.tre.exception.ToolException;
import org.apache.commons.fileupload.FileItem;
import org.apache.commons.fileupload.FileItemFactory;
import org.apache.commons.fileupload.disk.DiskFileItemFactory;
import org.apache.commons.fileupload.servlet.ServletFileUpload;
import org.apache.poi.openxml4j.exceptions.InvalidFormatException;
import org.apache.poi.ss.usermodel.*;


import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.*;
import java.net.URLDecoder;
import java.util.*;
import java.util.stream.Collectors;

import static com.fy.tool.toolmaker.util.PinyinUtil.removeSpecialChar;

public class ToolMaker extends ActionToolBase {

    // https://www.wetoband.com/tre//runToolWithToolShopToolID?toolID=4389333&bandID=7600025278&gid=7600025278&param=
    // https://www.wetoband.com/tre//runToolWithToolShopToolID?toolID=${toolID}&bandID=${bandID}&gid=${bandID}&param=
    private String tempDir = System.getProperty("java.io.tmpdir");

    CoreRemoteService coreRemoteService = new CoreRemoteServiceImpl();

    @Action
    public String hello(HttpServletRequest request) {
        return RequestUtils.getStringParameter(request, "arg1");
    }
//从数据库中获取所有数据表的名字
    @Action
    public Map<String, Object> getTables(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<String, Object>();
        String databaseName = RequestUtils.getStringParameter(request, "databaseName");
        IToolMakerService toolMakerService = null;
        try {
            toolMakerService = getBean(IToolMakerService.class);
            List<Map<String, Object>> tables = toolMakerService.getTables(databaseName);
            result.put("data", tables);
            result.put("code", 200);
        } catch (Exception e) {
            result.put("message", e.getMessage());
            result.put("code", 500);
            e.printStackTrace();
        }
        return result;
    }

    @Action
    public Map<String, Object> getTableFields(HttpServletRequest request) {
        Map<String, Object> result = new HashMap<String, Object>();
        String tableName = RequestUtils.getStringParameter(request, "tableName");
        String databaseName = RequestUtils.getStringParameter(request, "databaseName");
        IToolMakerService toolMakerService = null;
        try {
            toolMakerService = getBean(IToolMakerService.class);
            List<Map<String, Object>> tableFields = toolMakerService.getTableFields(tableName, databaseName);
            result.put("data", tableFields);
            result.put("code", 200);
        } catch (Exception e) {
            result.put("message", e.getMessage());
            result.put("code", 500);
            e.printStackTrace();
        }
        return result;
    }

    @Action
    public Map<String, Object> showDataBases(HttpServletRequest request){
        Map<String, Object> result = new HashMap<String, Object>();
        String account = RequestUtils.getStringParameter(request, "account");
        String password = RequestUtils.getStringParameter(request, "password");
        IToolMakerService makerService = null;
        try {
            makerService = getBean(IToolMakerService.class);
            List<Map<String,Object>> data = makerService.showDataBases();
            result.put("code", 200);
            result.put("data", data);
            return result;
        } catch (Exception e) {
            result.put("code", 500);
            result.put("message", e.getMessage());
            return result;
        }
    }

    @Action
    public Map<String, Object> getAllTools(HttpServletRequest request){
        Map<String, Object> result = new HashMap<String, Object>();
        Long bandId = RequestUtils.getLongParameter(request,"bandId");
        try {
            JSONObject toolsInBand = coreRemoteService.getToolsInBand(bandId);
            result.put("code", 200);
            result.put("data", toolsInBand);
            return result;
        } catch (Exception e) {
            result.put("code", 500);
            result.put("message", e.getMessage());
            return result;
        }
    }

    @Action
    public Map<String, Object> upload(HttpServletRequest request) {
        HashMap<String, Object> result = new HashMap<>();
        try {
            List<FileItem> items = getUploadFiles("file");
            Optional<FileItem> excel = getExcelFileItem(items);

            List<ExcelTable> tables = parseTableInfo(excel);

            result.put("code", 200);
            result.put("tables", tables);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return result;
    }

    private List<ExcelTable> parseTableInfo(Optional<FileItem> excel) throws IOException, InvalidFormatException {

        if (!excel.isPresent()){
            throw new ToolException("", ErrorCode.TOOL_INNER_ERROR);
        }

        Workbook workbook = WorkbookFactory.create(excel.get().getInputStream());
        List<ExcelTable> tables =  new ArrayList<>(workbook.getNumberOfSheets());

        for (int i = 0; i < workbook.getNumberOfSheets(); i++){
            ExcelTable table = new ExcelTable();
            Sheet sheet = workbook.getSheetAt(i);

            table.setTableName(sheet.getSheetName());

            List<Field> fields = new ArrayList<>();
            //在数据库里转化为拼音
            sheet.getRow(0).forEach(c -> fields.add(new Field(PinyinUtil.getPingYin(c.getStringCellValue()), "text",c.getStringCellValue(), sheet.getSheetName() )));

            table.setFields(fields);
            tables.add(table);
        }


        return  tables;
    }

    private Optional<FileItem> getExcelFileItem(List<FileItem> items) {
        for (FileItem item : items) {
            // 文件类型的表单
            if (item.isFormField()) {
                break;
            }

            String fileName = item.getName();
            if (fileName == null) {
                break;
            }

            if (!fileName.endsWith(".xlsx") && !fileName.endsWith("xls")) {
                throw new ToolException("文件上传的类型错误, 请上传 xlsx 或 xls 格式的 文件。", ErrorCode.TOOL_INNER_ERROR);
            }

            return Optional.of(item);
        }

        return Optional.empty();
    }

//    @Action
//    public Map<String, Object> preview(HttpServletRequest request) {
//        String toolName = RequestUtils.getStringParameter(request, "toolName");
//        String toolNamePinYin = PinyinUtil.getPingYin(toolName);
//        String outputPath = tempDir + File.separator + "toolmaker_" + toolNamePinYin;
//        String tempPath = request.getServletContext().getRealPath("temp");
//        String resource = outputPath + File.separator + "WebRoot" + File.separator + "resource";
//        moveFiles(resource, tempPath + File.separator + toolNamePinYin);
//        // 移动好文件后，再把main.jsp文件也移动过来，并更改名字为main.html
//        HashMap<String, Object> result = new HashMap<>();
//        result.put("url", "http://localhost:8080/temp/"+tempPath + File.separator + toolNamePinYin+ File.separator + )
//        return ;
//    }

    /**
     * 复制文件夹及文件
     *  1.如果是源文件路径一个文件夹，则在目的路径下创建一个相同的文件夹，并遍历该文件夹下的所有文件
     *      - 由遍历得到的每一个文件，再调用本方法
     *  2.如果是一个文件，直接复制
     * @return
     */
//    private static void moveFiles(String originPath, String destinationPath) {
//        File resourceFiles = new File(originPath);
//        if(resourceFiles.isDirectory()) {
//            // 如果 resourceFiles 是一个目录，则在目的路径下也创建一个相同的目录
//            File createDir = new File(destinationPath, resourceFiles.getName());
//            if(!createDir.exists()) {
//                createDir.mkdir();
//            }
//            File[] files = resourceFiles.listFiles();
//            for (File file:
//                    files) {
//                // 在 tempPath目录下创建文件
//                String newDesPath = destinationPath + File.separator + file.getName();
//                moveFiles(file.getAbsolutePath(), newDesPath);
//            }
//        } else { // 说明是一个文件
//            try(FileInputStream fis = new FileInputStream(resourceFiles);
//                FileOutputStream fos = new FileOutputStream(destinationPath)
//            ) {
//                int copy = IOUtils.copy(fis, fos);
//                System.out.print("源文件：" + originPath + "，转移到===》");
//                System.out.println("目的路径下：" + destinationPath);
//            } catch (IOException e) {
//                e.printStackTrace();
//            }
//        }
//    }

    @Action
    //需要另外传一个tables代表数据库的tables，然后转化成dbtables，且 saveToDB不必调用
    public Map<String, Object> makeTool(HttpServletRequest request) throws UnsupportedEncodingException {
        HashMap<String, Object> result = new HashMap<>();
        HashMap<String, Object> data = new HashMap<>();

        Boolean isFromDatabase=RequestUtils.getBooleanParameter(request,"isFromDatabase");
        String connectCondition=RequestUtils.getStringParameter(request,"connectCondition");


        String tablesStr = RequestUtils.getStringParameter(request, "tables");
        List<ExcelTable> tables = JSONObject.parseArray(tablesStr, ExcelTable.class);

        //改动
        //获取分类内容
        String classifyKey = RequestUtils.getStringParameter(request, "classifyKey");
        String classifyStr = RequestUtils.getStringParameter(request, "classifyValue");
        List<Classify> classifyValues = JSONObject.parseArray(classifyStr, Classify.class);

        //改动
        //获取搜索内容
        String searchStr = RequestUtils.getStringParameter(request, "searchValue");
        List<SearchList> searchList = JSONObject.parseArray(searchStr, SearchList.class);

        //改动
        //获取调用工具
        Boolean hasToolControl=RequestUtils.getBooleanParameter(request,"hasToolControl");
        String toolControlId=RequestUtils.getStringParameter(request,"toolControlId");
        String toolControlDes=RequestUtils.getStringParameter(request,"toolControlDes");

        String toolInfoStr = RequestUtils.getStringParameter(request, "toolInfo");
        ToolInfo toolInfo = JSONObject.parseObject(toolInfoStr, ToolInfo.class);
        /*****************************************************stop****************************************/
        Boolean remoteCall = RequestUtils.getBooleanParameter(request, "remoteCall");
        List<String> fieldNames;
        if (remoteCall != null && remoteCall) {
            String s = URLDecoder.decode(RequestUtils.getStringParameter(request, "fieldNames"), "utf-8");
            if (s != null && !s.trim().isEmpty()) {
                fieldNames = FormatUtils.arrayStr2List(s, false);
            } else {
                fieldNames = Collections.emptyList();
            }
        } else {
            fieldNames = RequestUtils.getJsonArrayParameter(request, "fieldNames");
        }
        //传了没用
        List<String> fieldTypes = RequestUtils.getJsonArrayParameter(request, "fieldTypes");
        //没传
        List<String> searchFieldsIndex = RequestUtils.getJsonArrayParameter(request, "searchFields");
        /*****************************************************stop****************************************/
         /*           List<DbColumn> columns = dbTable.getColumns();
            // 加入公式字段
            for (int i = 0; i < formulas.size(); i++) {
                String formulaName = PinyinUtil.getPingYin(formulaNames.get(i));
                DbColumn dbColumn = new DbColumn();
                dbColumn.setName(formulaName); // a1+a2
                dbColumn.setType("varchar(255)");
                dbColumn.setFormulaName(formulaNames.get(i));
                dbColumn.setComment(formulas.get(i)); // aaa
                dbColumn.setChangedName(ToolMakerUtil.underLineToCamelCase(formulaName)); // aaa
                columns.add(dbColumn);
            }
            dbTable.setColumns(columns);*/
        /*****************************************************stop****************************************/
        // 获取公式字段
        List<String> formulaNames = RequestUtils.getJsonArrayParameter(request, "formulaNames");
        List<String> formulas = RequestUtils.getJsonArrayParameter(request, "formulas");

        // 工具名称的汉字转化为拼音
        String toolNamePinYin = PinyinUtil.getCodePinPin(removeSpecialChar(toolInfo.getName()));
        data.put("toolName", toolNamePinYin);

        // 是否是生成视图工具
        Boolean nViewTool = RequestUtils.getBooleanParameter(request, "nViewTool");
        if(nViewTool == null) {
            nViewTool = true; // 表示不是视图工具
        }
        // 获取视图来源id
        Integer parentId = RequestUtils.getIntegerParameter(request, "parentToolId");
        String parentToolName = RequestUtils.getStringParameter(request, "parentToolName");

        String tableName = toolNamePinYin;
        if(parentId != null) {
            tableName = parentToolName;
        }
        /*****************************************************stop****************************************/
        /*****************************************************stop****************************************/
        if (searchFieldsIndex != null && !searchFieldsIndex.isEmpty()) {
            List<String> searchFields = new ArrayList<>(searchFieldsIndex.size());
            searchFieldsIndex.forEach(field -> {
                searchFields.add("column" + field);
            });

            //config.setSearchFields(searchFields);
        }
        /*****************************************************stop****************************************/
        // TODO sql 注入问题
        try {
            List<DbTable> dbTables=new ArrayList<>();
            DbTable dbTable=new DbTable();
            //将传过来的table转化为dbtables，
            if(!isFromDatabase) {
            dbTables = tables.stream().map(this::generateTables).collect(Collectors.toList());
            dbTable = generateTables(tables.get(0));
            }else {
                dbTables = tables.stream().map(this::generateTablesFromDB).collect(Collectors.toList());
                dbTable = generateTablesFromDB(tables.get(0));
            }

            // 生成工具
            ToolConfiguration config = new ToolConfiguration();
            config.setToolName(toolInfo.getName());
            config.setPinyinOfToolName(toolNamePinYin);
            config.setToolDescription(toolInfo.getDescription());
            config.setTable(dbTable);

            //实际只用了这个
            config.setTables(dbTables);

            config.setExcelTables(tables);
            config.setClassName(toolNamePinYin);
            config.setPackageName("com.wetoband.tool.toolmaker_" + PinyinUtil.getPingYin(removeSpecialChar(toolInfo.getName())));
            config.setNViewTool(nViewTool);
            config.setCompany(toolInfo.getCompany());

            //Excel导入导出
            config.setHasExport(toolInfo.getExportData());
            config.setHasImport(toolInfo.getImportData());
            //增删改查
            config.setHasAdd(toolInfo.getAdd());
            //改动
            config.setHasDeleteControl(toolInfo.getDeleteControl());
            config.setHasUpdateControl(toolInfo.getUpdateControl());
            config.setHasViewControl(toolInfo.getViewControl());
            config.setClassifyList(classifyValues);
            config.setSearchList(searchList);
            config.setClassifyKey(classifyKey);
            config.setHasToolControl(hasToolControl);
            config.setToolControlDes(toolControlDes);
            config.setToolControlId(toolControlId);
            config.setIsFromDatabase(isFromDatabase);
            config.setConnectCondition(connectCondition);


            String outputPath = generateTool(config);
            data.put("outputDir", outputPath);

            //工具信息保存到了一张表里
            //saveToDB(fieldNames, toolInfo, formulaNames, toolNamePinYin, parentId, parentToolName);

        } catch (Exception e) {
            e.printStackTrace();
            result.put("code", 500);

            result.put("message", this.getResourcePath() + "生成数据表失败" + e.getMessage() + e.getCause() + Arrays.toString(e.getStackTrace()));
            return result;
        }

        result.put("code", 200);
        result.put("data", data);
        return result;
    }




    private String generateTool(ToolConfiguration config) throws Exception {
        com.fy.tool.toolmaker.core.ToolMaker maker = new com.fy.tool.toolmaker.core.ToolMaker();
        String outputPath = tempDir + File.separator + "toolmaker_" + config.getPinyinOfToolName();
        maker.setOutputPath(outputPath);
        maker.setToolConfiguration(config);
        maker.setTemplatePath(this.getResourcePath() + File.separator + "other" + File.separator + "templates");
        System.out.println("正在生成工具");
        maker.generate();
        System.out.println("生成工具成功");
        System.out.println("输出项目目录为：" + outputPath);
        return outputPath;
    }

    private void saveToDB(List<String> fieldNames, ToolInfo toolInfo, List<String> formulaNames, String toolName, Integer parentId, String parentToolName) throws Exception {
        // 添加到数据库中
        IToolMakerService toolMakerService = getBean(IToolMakerService.class);
        ToolMakerEntity toolMakerEntity = new ToolMakerEntity();
        toolMakerEntity.setId(null);
        toolMakerEntity.setToolName(toolInfo.getName());
        toolMakerEntity.setCreateTime(new Date());
        if(parentId !=null) {
            toolMakerEntity.setViewSource(parentId);
            toolMakerEntity.setParentToolName(parentToolName);
        } else {
            toolMakerEntity.setViewSource(0);
            toolMakerEntity.setParentToolName("");
        }
        toolMakerEntity.setIsDeploy(0);
        StringJoiner sj = new StringJoiner(",");
        fieldNames.forEach(sj::add);
        toolMakerEntity.setFields(sj.toString());
        toolMakerEntity.setToolDescription(toolInfo.getDescription());
        sj = new StringJoiner(",");
        formulaNames.forEach(sj::add);
        toolMakerEntity.setFormulaFields(sj.toString());
        toolMakerEntity.setDataTableName(toolName);
        String userAccount = this.getUserAccount();
        toolMakerEntity.setToolOtherName(userAccount + "_" + toolName + "_" + System.currentTimeMillis()); // 默认设置为当前用户账号+_+工具名拼音
        toolMakerService.addTool(toolMakerEntity);
    }
    private DbTable generateTables(ExcelTable table) {
        DbTable dbTable = new DbTable();
        DbColumn id = new DbColumn();
        id.setType("NUMERIC");
        id.setComment("id");
        id.setName("id");
        id.setChangedName("id");
        id.setShowName("id");

        dbTable.setName(ToolMakerUtil.camelCaseToUnderLine(removeSpecialChar(table.getTableName())));
        dbTable.setNameChinese(table.getTableName());
        dbTable.setPinyinOfEntityName(PinyinUtil.getCodePinPin(removeSpecialChar(table.getTableName())));
        List<DbColumn> dbColumns = new ArrayList<>(table.getFields().size());
        dbColumns.add(id);
        for (int i = 0; i < table.getFields().size(); i++) {
            DbColumn dbColumn = new DbColumn();
            if (Objects.isNull(table.getFields().get(i))) {
                dbColumn.setType("varchar(255)");
            } else {
                dbColumn.setType(table.getFields().get(i).getType());
            }
            //数据库中的列名
            dbColumn.setName(table.getFields().get(i).getName());
            //转化为实体的列名（从下划线到驼峰）
            dbColumn.setChangedName(ToolMakerUtil.underLineToCamelCase(table.getFields().get(i).getName()));
            //在表格中显示的列名
            if(table.getFields().get(i).getShowName()==null||table.getFields().get(i).getShowName().equals("")){
              dbColumn.setShowName(table.getFields().get(i).getName());
                //列名的注释
                dbColumn.setComment(table.getFields().get(i).getName());
            } else{
                dbColumn.setShowName(table.getFields().get(i).getShowName());
                //列名的注释
                dbColumn.setComment(table.getFields().get(i).getShowName());
            }
            //不重复设置id
            if(!dbColumn.getName().equals("id")){
                dbColumns.add(dbColumn);
            }
        }
        dbTable.setColumns(dbColumns);
        return dbTable;
    }
    private DbTable generateTablesFromDB(ExcelTable table) {
        DbTable dbTable = new DbTable();
        dbTable.setName(ToolMakerUtil.camelCaseToUnderLine(removeSpecialChar(table.getTableName())));
        dbTable.setNameChinese(table.getTableName());
        dbTable.setPinyinOfEntityName(PinyinUtil.getCodePinPin(removeSpecialChar(table.getTableName())));
        List<DbColumn> dbColumns = new ArrayList<>(table.getFields().size());
        for (int i = 0; i < table.getFields().size(); i++) {
            DbColumn dbColumn = new DbColumn();
            if (Objects.isNull(table.getFields().get(i))) {
                dbColumn.setType("varchar(255)");
            } else {
                dbColumn.setType(table.getFields().get(i).getType());
            }
            dbColumn.setName(table.getFields().get(i).getName());
            dbColumn.setChangedName(ToolMakerUtil.underLineToCamelCase(table.getFields().get(i).getName()));
            if(table.getFields().get(i).getShowName()==null){
                dbColumn.setShowName(table.getFields().get(i).getName());
                dbColumn.setComment(table.getFields().get(i).getName());
            } else{
                dbColumn.setShowName(table.getFields().get(i).getShowName());
                dbColumn.setComment(table.getFields().get(i).getShowName());
            }
            if(table.getFields().get(i).getParentTable()!=null){
                dbColumn.setParentTable(table.getFields().get(i).getParentTable());
            }
            dbColumns.add(dbColumn);
        }
        dbTable.setColumns(dbColumns);
        return dbTable;
    }

    /**
     *  旧方法：将前端传入的excel表格信息转化为标准的数据库中的使用的tables
     *  新增了一个id
     *  把excel中的列名转化为了注释，数据库中的列名改为了column_i的形式，实体名是驼峰式的columnI
      */
//    private DbTable generateTables(ExcelTable table) {
//        DbTable dbTable = new DbTable();
//        //这个方法给每个字母中间都加了一个下划线
//        dbTable.setName(PinyinUtil.getDbPinYin(removeSpecialChar(table.getTableName())));
//        dbTable.setNameChinese(table.getTableName());
//        dbTable.setPinyinOfEntityName(PinyinUtil.getCodePinPin(removeSpecialChar(table.getTableName())));
//
//        DbColumn id = new DbColumn();
//        id.setType("NUMERIC");
//        id.setComment("id");
//        id.setName("id");
//        id.setChangedName("id");
//        List<DbColumn> dbColumns = new ArrayList<>(table.getFields().size());
//        dbColumns.add(id);
//
//        for (int i = 0; i < table.getFields().size(); i++) {
//            DbColumn dbColumn = new DbColumn();
//            if (Objects.isNull(table.getFields().get(i))) {
//                dbColumn.setType("varchar(255)");
//            } else {
//                dbColumn.setType(table.getFields().get(i).getType());
//            }
//            dbColumn.setComment(table.getFields().get(i).getName());
//            dbColumn.setName("column_" + i);
//            dbColumn.setChangedName(ToolMakerUtil.underLineToCamelCase("column_" + i));
//            dbColumns.add(dbColumn);
//        }
//        dbTable.setColumns(dbColumns);
//        return dbTable;
//    }

    @Action
    public void download(HttpServletRequest request, HttpServletResponse response) {
        String toolName = PinyinUtil.getPingYin(removeSpecialChar(RequestUtils.getStringParameter(request, "toolName")));
        if (toolName == null || toolName.trim().isEmpty()) {
            System.out.println("工具名称为空");
            return;
        }
        File projectDir = new File(tempDir + File.separator + "toolmaker_" + toolName);
        if (!projectDir.exists()) {
            System.out.println("工具工程目录不存在");
            return;
        }
        try {
            String command = "";
            if (System.getProperty("os.name").contains("Linux")) {
                command = "sh package.sh";
            }else{
                command = "cmd /c package.bat";
            }

//            Process process = Runtime.getRuntime().exec("python compile.py", null, projectDir);
            Process process = Runtime.getRuntime().exec(command, null, projectDir);
            readProcessOutput(process);
            process.waitFor();

            File file = new File(projectDir.getPath() + File.separator + "target" + File.separator + toolName + "-1.jar");
            InputStream ins = null;
            ins = new FileInputStream(file);

            /* 设置文件ContentType类型，这样设置，会自动判断下载文件类型 */
            response.setContentType("multipart/form-data");
            /* 设置文件头：最后一个参数是设置下载文件名 */
            response.setHeader("Content-Disposition", "attachment;filename=" + toolName + ".jar");
            OutputStream os = response.getOutputStream();
            byte[] b = new byte[1024];
            int len;
            while ((len = ins.read(b)) > 0) {
                os.write(b, 0, len);
            }
            os.flush();
            os.close();
            ins.close();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        } catch (InterruptedException e) {
            System.out.println("调用外部编译程序失败");
            e.printStackTrace();
        }
    }


    /**
     * 打印进程输出
     *
     * @param process 进程
     */
    private static void readProcessOutput(final Process process) {
        // 将进程的正常输出在 System.out 中打印，进程的错误输出在 System.err 中打印
        read(process.getInputStream(), System.out);
        read(process.getErrorStream(), System.err);
    }

    // 读取输入流
    private static void read(InputStream inputStream, PrintStream out) {
        try (BufferedReader reader = new BufferedReader(new InputStreamReader(inputStream));) {

            String line;
            while ((line = reader.readLine()) != null) {
                out.println(line);
            }

        } catch (IOException e) {
            e.printStackTrace();
        } finally {

            try {
                inputStream.close();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }


    @Action
    public void downloadSource(HttpServletRequest request, HttpServletResponse response) {

        String toolName = PinyinUtil.getPingYin(removeSpecialChar(RequestUtils.getStringParameter(request, "toolName")));
        if (toolName == null || toolName.trim().isEmpty()) {
            System.out.println("工具名称为空");
            return;
        }
        File projectDir = new File(tempDir + File.separator + "toolmaker_" + toolName);
        if (!projectDir.exists()) {
            System.out.println("工具工程目录不存在");
            return;
        }

        File toolZip = new File(projectDir, "tool.jar");
        if (toolZip.exists()) {
            toolZip.delete();
        }

        File srcZip = new File(projectDir, toolName + "-src.zip");
        if (srcZip.exists()) {
            srcZip.delete();
        }


        String outputFileName = toolName + "-src.zip";
        ZipUtil.zipFolder(projectDir.getAbsolutePath(), projectDir.getAbsolutePath(), outputFileName, "UTF-8", "templib");

        File file = new File(projectDir.getAbsolutePath() + File.separator + outputFileName);
        InputStream ins = null;
        try {
            ins = new FileInputStream(file);

            /* 设置文件ContentType类型，这样设置，会自动判断下载文件类型 */
            response.setContentType("multipart/form-data");
            /* 设置文件头：最后一个参数是设置下载文件名 */
            response.setHeader("Content-Disposition", "attachment;filename=" + file.getName());
            OutputStream os = response.getOutputStream();
            byte[] b = new byte[1024];
            int len;
            while ((len = ins.read(b)) > 0) {
                os.write(b, 0, len);
            }
            os.flush();
            os.close();
            ins.close();
            response.flushBuffer();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
    }

    @Action
    public void downloadSql(HttpServletRequest request, HttpServletResponse response) {
        String toolName = PinyinUtil.getPingYin(removeSpecialChar(RequestUtils.getStringParameter(request, "toolName")));
        if (toolName == null || toolName.trim().isEmpty()) {
            System.out.println("工具名称为空");
            return;
        }
        File file = new File(tempDir + File.separator + "toolmaker_" + toolName + File.separator + "tempResources" + File.separator + toolName + ".sql");
        if (!file.exists()) {
            System.out.println("文件不存在");
            return;
        }

        try (OutputStream os = response.getOutputStream();) {
            InputStream ins = new FileInputStream(file);

            /* 设置文件ContentType类型，这样设置，会自动判断下载文件类型 */
            response.setContentType("multipart/form-data");
            /* 设置文件头：最后一个参数是设置下载文件名 */
            response.setHeader("Content-Disposition", "attachment;filename=" + file.getName());

            byte[] b = new byte[1024];
            int len;
            while ((len = ins.read(b)) > 0) {
                os.write(b, 0, len);
            }
            os.flush();
            os.close();
            ins.close();
            response.flushBuffer();
        } catch (IOException ioe) {
            ioe.printStackTrace();
        }
    }

//    @BeanDeclare(forClass = CoreRemoteService.class, scope = BeanScope.TEMPORY)
//    private CoreRemoteService onDeclaringCoreRemoteService() {
//        return new CoreRemoteServiceImpl();
//    }

    @BeanDeclare(forClass = IToolMakerService.class, scope = BeanScope.TEMPORY)
    private IToolMakerService onDeclaringToolMakerService() {
        return new ToolMakerServiceImpl();
    }

    @BeanDeclare(forClass = IToolMakerDao.class, scope = BeanScope.TEMPORY)
    private IToolMakerDao onDeclaringToolMakerDao() throws Exception {
        return new ToolMakerDaoImpl();
    }
}
