package com.fy.tool.toolmaker;

import com.fy.tool.toolmaker.core.DbTable;
import com.fy.tool.toolmaker.core.ToolConfiguration;
import com.fy.tool.toolmaker.core.ToolMaker;
import com.fy.tool.toolmaker.core.ToolMakerUtil;

import java.util.Map;

public class Main {
    public static void main(String[] args) throws Exception {

        Map<String, DbTable> dbTables = ToolMakerUtil.getDbTables(ToolMakerUtil.getConnection());

        ToolConfiguration config = new ToolConfiguration();
        config.setToolName("人员管理工具");
        config.setPackageName("com.fy.tool.employee");
        config.setClassName("Employee");
        config.setTable(dbTables.get("employee"));

        ToolMaker maker = new ToolMaker();
        maker.setToolConfiguration(config);
        maker.setOutputPath("../Employee");
        maker.setTemplatePath("D:\\code\\wtb\\ToolMaker\\WebRoot\\resource\\other\\templates");
        maker.generate();
    }
}
