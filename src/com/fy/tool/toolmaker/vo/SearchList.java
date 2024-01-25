package com.fy.tool.toolmaker.vo;


import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;

@Data
@AllArgsConstructor
@NoArgsConstructor
public class SearchList implements Serializable {
    //搜索字段名称
    private String name;
    //搜索框描述
    private String searchDes;
}
