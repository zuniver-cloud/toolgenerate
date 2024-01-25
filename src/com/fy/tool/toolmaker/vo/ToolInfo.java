package com.fy.tool.toolmaker.vo;

import lombok.Data;

@Data
public class ToolInfo {
    private String name;
    private String description;
    private String company;
    private Boolean importData;
    private Boolean exportData;
    private Boolean add;
    private Boolean deleteControl;
    private Boolean viewControl;
    private Boolean updateControl;
}
