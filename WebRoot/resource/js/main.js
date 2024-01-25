let id = 0;
var vm = new Vue({
    el: '#app',
    data: {
        //定义连接条件
        connectCondition:'',
        //定义其他按钮的名称
        toolControlButton:'',
        //定义被选择的工具id
        selectedToolId:'',
        //存储当前帮区下的工具
        tools:[],
        //是否生成其他按钮
        toolUseControl:false,
        fieldsFromDatabase: [],
        hasDataBaseInfo: false,
        databaseInfo: {
            account:'',
            password: '',
        },
        props: {
            multiple: true,
            emitPath: false,
            // checkStrictly: true,
            lazy: true,
            lazyLoad(node, resolve) {
                console.log("hello"+node);
                const { level,isLeaf,value,parent } = node;
                console.log("isLeaf", isLeaf);
                if(isLeaf) { // 如果已经是叶子节点，不进行下面的步骤
                    resolve();
                    return;
                }
                var action;
                var data;
                var index;
                if(level == 1) {
                    action = "getTables";
                    data = {databaseName: value};
                    index = "table";
                    $.post(window.g_runToolUrl + '&action=' + action, data, function (res) {
                        console.log(res)
                        if(res.data && res.data.length > 0) {
                            const nodes = []
                            res.data.forEach( val => {
                                nodes.push({
                                    value: val[index],
                                    label: val[index],
                                    leaf: level >= 2
                                })
                            });
                            console.log("nodes",nodes)
                            // 通过调用resolve将子节点数据返回，通知组件数据加载完成
                            resolve(nodes);
                        } else {
                            resolve();
                        }
                    })
                } else if(level == 2) {
                    action = "getTableFields"
                    data = {databaseName: parent.value,tableName: value}
                    $.post(window.g_runToolUrl + '&action=' + action, data, function (res) {
                        console.log(res)
                        if(res.data && res.data.length > 0) {
                            const nodes = []
                            res.data.forEach( val => {
                                var nodedata={columnName:val.columnName,dataType:val.dataType,parentTable:value}
                                nodes.push({
                                    value: nodedata,
                                    label: val.columnName,
                                    leaf: level >= 2
                                })
                            });
                            console.log("nodes",nodes)
                            // 通过调用resolve将子节点数据返回，通知组件数据加载完成
                            resolve(nodes);
                        } else {
                            resolve();
                        }
                    })
                }
                // console.log(action)
                // console.log(data)
                // setTimeout(() => {
                //     const nodes = Array.from({ length: level + 1 })
                //         .map(item => ({
                //             value: ++id,
                //             label: `选项${id}`,
                //             leaf: level >= 2
                //         }));
                //     // 通过调用resolve将子节点数据返回，通知组件数据加载完成
                //     resolve(nodes);
                // }, 1000);
            },
        },
        options: [],
        dialogVisible: false,
        loading: true,
        fileList: [],
        //公式定义界面左边显示的已选择字段
        form: {
            fields: [],
        },
        //数据库上传的表格
        dbTables:[],
        //上传的表格
        tables: [
            // {
            //     tableName: '表1',
            //     fields: [
            //         {
            //             name: '',
            //             type: 'text'
            //             parentTable:''
            //         }
            //     ]
            // }
        ],
        //改动4：这个表存储修改过后对应的字段信息
        changedTables:[
            {
                // tableName:'',
                // fields:[
                //     {
                //         name:'',
                //         showName:'',
                //         type:'',
                //         parentTable:'',
                //     }
                // ]
            }
        ],
        isFromDatabase:false,

        selectTable: '',
        toolForm: {
            name: '',
            description: '',
            company: '',
            importData: false,
            exportData: false,
            add: false,
            // control: true,
            deleteControl:false,
            // addControl:false,
            updateControl:false,
            viewControl:false
        },
        formulaForm: {
            fields: [],
        },
        searchForm: {
            fields: [{name: '', searchDes: ''}],
        },
        classifyForm:{
            classifyKey:'',
            classifyValue:[{value:'',name:''}],
        },
        toolNamePinyin: '',
        success: false,
        step: 1,
        fade: 'right',
        buildBtnDisabled: false
    },
    mounted: function () {
        console.log("hello")
        this.connectDatabase();
        this.getTools();
    },
    watch: {
        fieldsFromDatabase: function (newVal, oldVal) {
            console.log("oldVal", oldVal);
            console.log("newVal", newVal);
        }
    },
    methods: {
        //获取所有的工具信息
        getTools(){
            console.log("this is getalltools")
            var action = "getAllTools";
            var data = {bandId: window.g_bandId};
            var that = this;
            $.post(window.g_runToolUrl + '&action=' + action, data, function (res) {
                if(res.data.rows && res.data.rows.length > 0) {
                    res.data.rows.forEach( val => {
                        that.tools.push({label: val.name, value: val.toolShopToolID});
                    });
                    console.log(that.tools)
                }
            })
        },
        handleChange(value) {
            console.log("handleChange", value)
        },
        handleExpandChange(value) {
            console.log("handleExpandChange",value)
        },
        connectDatabase() {
            var action = "showDataBases";
            var data = [];
            var that = this;
            $.post(window.g_runToolUrl + '&action=' + action, data, function (res) {
                console.log(res)
                if(res.data && res.data.length > 0) {
                    res.data.forEach( val => {
                        that.options.push({label: val.database, value: val.database});
                    });
                    console.log(that.options)
                    that.hasDataBaseInfo = true;
                }
            })
        },
        handleClose(done) {
            done();
        },
        indexMethod(index) {
            return "a"+(index+1);
        },
        drag() {
            console.log("hello")
        },
        editExcelHelp() {
            this.$alert(`
                <span>上传的xls格式的文件请按照如下格式之一：</span>
                <ol>
                   <li><img src="${window.g_resourceUrl}images/model1.png" style="border: 1px solid red;max-width: 200px;"/></li>             
                   <li><img src="${window.g_resourceUrl}images/model2.png" style="border: 1px solid red;max-width: 200px;" /></li>             
                </ol>
                <span><b>注意：文件以UTF-8的格式保存！以防乱码！</b></span>
            `, '上传Excel表格格式说明', {
                confirmButtonText: '确定',
                dangerouslyUseHTMLString: true
            });
        },
        onUpload: function (res, file, fileList) {
            if (res.code === 200) {
                for (let i = 0; i < res.tables[0].fields.length; i++) {
                    var field = res.tables[0].fields[i]
                    this.form.fields.push({name: field.name, type: 'text'})
                }

                this.tables = res.tables
                this.step = 3;
                this.fade = 'right';
            } else if (res.code === 201) {
                this.$message.error(res.msg);
            }
        },
        handleTabsEdit(targetName, action) {
            if (action === 'add') {
                this.tables.push({
                    tableName: '表' + (this.tables.length + 1),
                    fields: [
                        {
                            name: '',
                            type: 'text'
                        }
                    ]
                });

                this.selectTable = (this.tables.length - 1) + ''
            }
            if (action === 'remove') {
                if (this.tables.length === 1) {
                    this.$message({type: 'warning', message: "必须有一张表！"});
                    return
                }

                if (~~targetName === this.tables.length - 1 && targetName === this.selectTable){
                    this.selectTable = (this.tables.length - 2) + ''
                }else if(~~targetName < ~~this.selectTable){
                    this.selectTable = ((~~this.selectTable) - 1) + ''
                }

                this.tables.splice(~~targetName, 1)
            }
        },
        editTableName(index){
            var label = this.tables[index].tableName
            this.$prompt('', ' 修改表名', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                inputValue: label,
                inputPlaceholder: '表名必须包含中文或英文'
            }).then(({ value }) => {
                 this.tables[index].tableName = value
            }).catch(() => {
            });
        },
        addHeader() {
            this.tables[~~this.selectTable].fields.push({
                name: '', type: 'text',showName:'',
            })

          /*  let isIncludeEmpty = this.form.fields.some(field => field.name.trim() == "");
            console.log(isIncludeEmpty)
            if (isIncludeEmpty) {
                this.$message({type: 'warning', message: "请填写已创建的字段！"});
                return;
            }*/
            // this.form.fields.push({name: '', type: 'text'});
        },
        removeHeader: function (index) {

            if (this.tables[~~this.selectTable].fields.length === 1){
                this.$message({type: 'warning', message: "必须有一个字段！"});
                return;
            }
            this.tables[~~this.selectTable].fields.splice(index, 1)
            // this.form.fields.splice(index, 1)
        },
        addFormula() {
            let isIncludeEmpty = this.formulaForm.fields.some(field => field.name.trim() == "" || field.formula.trim() == "");
            console.log(isIncludeEmpty)
            if (isIncludeEmpty) {
                this.$message({type: 'warning', message: "请填写已创建的字段！"});
                return;
            }
            if (this.formulaForm.fields.length > 0 && !this.checkFormula()) {
                return;
            }
            this.formulaForm.fields.push({name: '', formula: ''});
        },
        //添加方法：增加搜索输入框
        addSearchForm() {
            let isIncludeEmpty = this.searchForm.fields.some(field => field.name.trim() == "" || field.searchDes.trim() == "");
            console.log(isIncludeEmpty)
            if (isIncludeEmpty) {
                this.$message({type: 'warning', message: "非法输入！"});
                return;
            }
            this.searchForm.fields.push({name: '', searchDes: ''});
        },
        //添加方法：增加分类按钮
        addClassifyForm() {
            if (this.classifyForm.classifyValue.some(field => field.name.trim() == "" )) {
                this.$message({type: 'warning', message: "请输入数据！"});
                return;
            }
            this.classifyForm.classifyValue.push({name:''});
        },
        removeAllFormula() {
            if (this.formulaForm.fields.length > 0) {
                this.$confirm('此操作将删除所有字段，是否继续？', '提示', {
                    confirmButtonText: '确定',
                    cancelButtonText: '取消',
                    type: 'warning'
                }).then(() => {
                    this.formulaForm.fields = [];
                    this.$message({
                        type: 'success',
                        message: '删除成功！'
                    })
                }).catch(() => {
                });
            }
        },
        removeFormula(index) {
            this.formulaForm.fields.splice(index, 1)
        },
        //添加方法:删除搜索框
        removeSearch(index) {
            this.searchForm.fields.splice(index, 1)
        },
        //添加方法:删除分类框
        removeClassify(index) {
            this.classifyForm.classifyValue.splice(index, 1)
        },
        makeTool() {
            if (!this.toolForm.name) {
                this.$alert('请输入工具名', '警告', {
                    confirmButtonText: '确定'
                });
                return;
            }

            if(!this.toolForm.description.trim().length > 100) {
                this.$alert('描述字数不可多于100个字符', '警告', {
                    confirmButtonText: '确定'
                });
                return;
            }

            var that = this;

            // var sfs = [];
            // for (var i in that.form.fields) {
            //     if (that.form.fields[i].search) {
            //         sfs.push(i);
            //     }
            // }
            var data = {
                connectCondition:this.connectCondition,
                //db方式
                // dbTables:JSON.stringify(this.dbTables),
                isFromDatabase:this.isFromDatabase,
                //表格方式,改动4,代表所有表格
                tables: JSON.stringify(this.tables),
                //单独传入的列信息
                fieldNames: JSON.stringify(that.form.fields.map(function (f) {
                    return f.name
                })),
                fieldTypes: JSON.stringify(that.form.fields.map(function (f) {
                    return f.type
                })),
                //工具描述信息+原来的功能定制
                toolInfo: JSON.stringify(this.toolForm),
                toolName: this.toolForm.name,
                toolDescription: this.toolForm.description,
                // searchFields: JSON.stringify(sfs),
                //公式部分
                // formulaNames: JSON.stringify(that.formulaForm.fields.map(function (f) {
                //     return f.name
                // })),
                // formulas: JSON.stringify(that.formulaForm.fields.map(function (f) {
                //     return f.formula;
                // })),
                //改动,功能定制部分
                classifyKey:this.classifyForm.classifyKey,
                classifyValue: JSON.stringify(this.classifyForm.classifyValue),
                searchValue:JSON.stringify( this.searchForm.fields),
                hasToolControl:this.toolUseControl,
                toolControlId:this.selectedToolId,
                toolControlDes:this.toolControlButton,
            };
            console.log(this.classifyForm.classifyKey)
            that.postForm('makeTool', data)
        },
        postForm: function (action, data) {
            var that = this;
            that.buildBtnDisabled = true;
            $.post(window.g_runToolUrl + '&action=' + action, data, function (res) {
                that.buildBtnDisabled = false;
                if (res.code === 200) {
                    that.toolNamePinyin = res.data.toolName
                    that.success = true;
                    that.step++;
                } else if (res.code > 500) {
                    that.success = false;
                    alert(res.message)
                } else {
                    that.success = false;
                    alert('工具生成失败')
                }
            })
        },
        download: function () {
            var url = window.g_runToolUrl + '&action=download&toolName=' + this.toolNamePinyin;
            window.open(url)
        },
        downloadSource: function () {
            var url = window.g_runToolUrl + '&action=downloadSource&toolName=' + this.toolNamePinyin;
            window.open(url)
        },
        downloadSQL: function () {
            var url = window.g_runToolUrl + '&action=downloadSql&toolName=' + this.toolNamePinyin;
            window.open(url)
        },
        checkForm: function () {
            this.fade = 'right';
            if (this.step === 3) {
                //db
                // if (this.tables.length === 0&&this.dbTables.length === 0) {
                if (this.tables.length === 0) {
                    this.$alert('至少建一张表', '警告', {
                        confirmButtonText: '确定'
                    });
                    return;
                }

                for (let t in this.tables){
                    for (let i in this.tables[t].fields) {
                        let f = this.tables[t].fields[i];
                        if (!f.name) {

                            this.selectTable = t + ''

                            this.$nextTick(function () {
                                this.$refs['field-' + t + '-' + i][0].$el.querySelector('input').focus()
                            });
                            this.$alert('请输入字段名', '警告', {
                                confirmButtonText: '确定'
                            });
                            return;
                        }
                    }
                }

                ++vm.step;
            } else if (this.step === 4) {
            //     console.log(this.tables)
            //     for (let i in this.formulaForm.fields) {
            //         let f = this.formulaForm.fields[i];
            //         if (!f.name) {
            //             this.$alert('请输入字段名', '警告', {
            //                 confirmButtonText: '确定'
            //             });
            //             return;
            //         }
            //         if (!f.formula) {
            //             this.$alert('请输入公式', '警告', {
            //                 confirmButtonText: '确定'
            //             });
            //             return;
            //         }
            //         if (!this.checkFormula()) {
            //             return;
            //         }
            //     }
            //     ++vm.step;
            // } else if (this.step === 5) {
                ++vm.step;
            }else if (this.step === 2) { // 获取选择的数据表
                //fieldsFromDatabase绑定的级联选择框
                console.log(this.fieldsFromDatabase)
                if(this.fieldsFromDatabase.length > 0){//数据是否来自数据库？
                    if(this.tables.length === 0) {//第一次选择
                    this.isFromDatabase=true;//赋值
                    console.log(this.$refs.cascader.getCheckedNodes())
                    this.form.fields = this.fieldsFromDatabase.map( item => ({name: item.columnName, type: item.dataType}))
                    this.tables.push({
                        // tableName:  this.$refs.cascader.getCheckedNodes()[0].pathLabels[1],
                        tableName:'changeTableName',
                        fields: this.fieldsFromDatabase.map( item => ({name: item.columnName, type: item.dataType, parentTable: item.parentTable}))
                    });
                }else { //返回重选
                    this.form.fields = this.fieldsFromDatabase.map( item => ({name:  item.columnName, type: item.dataType}))
                    //先删除后赋值
                    this.isFromDatabase=true;
                    this.tables.pop();
                    this.tables.push({
                        tableName: 'changeTableName',
                        fields: this.fieldsFromDatabase.map( item => ({name: item.columnName, type: item.dataType, parentTable: item.parentTable}))
                    });
                }
                }
                ++vm.step;
                // if(this.fieldsFromDatabase.length > 0&&this.tables.length === 0) {
                //     console.log(this.$refs.cascader.getCheckedNodes())
                //     this.form.fields = this.fieldsFromDatabase.map( item => ({name: item, type: 'text'}))
                //    //赋值到table里
                //     this.tables.push({
                //         tableName: this.dbTableName,
                //         fields:  this.form.fields
                //     });
                // }else{
                //     this.form.fields = this.fieldsFromDatabase.map( item => ({name: item, type: 'text'}))
                //     //先删除后赋值
                //     this.tables.pop();
                //     this.tables.push({
                //         tableName: 'Sheet' + (this.tables.length + 1),
                //         fields:  this.form.fields
                //     });
                // }
                // ++vm.step;
            }
            else {//step==1
                ++this.step;
            }
        },

        reload() {
            location.reload();
        },
        checkFormula(formula) {
            // 合法字符：+-*/, {}[](), a1,A1
            if (formula && formula.match(/[^a\d{}\[\]()+\-*\/]/i)) {
                this.$message({
                    message: "请输入合法字符",
                    type: 'warning'
                });
                return false;
            }
            var len = 1; // 默认为一
            if (!formula) { // 如果为空
                len = this.formulaForm.fields.length;
            }
            try {
                for (let i = 0; i < len; i++) {
                    if (!formula) { // 如果为空，formula值从第一个开始检查
                        formula = this.formulaForm.fields[i].formula;
                    }
                    // 检查a 和 0-9
                    var temp;
                    this.form.fields.forEach((curVal, index) => {
                        let reg = new RegExp("a" + (index + 1) + "(?!\\w)", "gi");
                        console.log(reg)
                        formula = formula.replace(reg, 1);
                    })
                    temp = formula;
                    formula = "";
                    if (temp.includes("a")) {
                        this.$message({
                            message: 'a的下标越界，使用的变量范围是a1~' + "a" + this.form.fields.length,
                            type: 'warning'
                        })
                        return false;
                    }
                    // var temp = formula.replaceAll(/a[0-9]+/ig, '1');
                    console.log(temp)
                    let eval1 = eval(temp);
                    console.log(eval1)
                }
                return true;
            } catch (e) {
                this.$message({
                    message: '表达式有误，请检查是否出现单个字母a或者数字直接放在了a前',
                    type: 'warning'
                })
                return false;
            }
        },
    },
})