var mobileWidth = 768;
Vue.directive('longpress', {
    bind: function (el, binding, vNode) {
        // Make sure expression provided is a function
        if (typeof binding.value.handler !== 'function') {
            // Fetch name of component
            var compName = vNode.context.name
            // pass warning to console
            var warn = '[longpress:] provided expression ' + binding.expression + ' is not a function, but has to be'
            if (compName) { warn += 'Found in component ' + compName + ' ' }

            console.warn(warn)
        }

        // Define variable
        var pressTimer = null

        var start = function(e) {

            if (e.type === 'click' && e.button !== 0) {
                return;
            }

            if (pressTimer === null) {
                pressTimer = setTimeout(function() {
                    // Run function
                    handler()
                }, 600)
            }
        }

        // Cancel Timeout
        var cancel = function(e) {
            // Check if timer has a value or not
            if (pressTimer !== null) {
                clearTimeout(pressTimer)
                pressTimer = null
            }
        }
        // Run Function
        var handler = function(e) {
            binding.value.handler(binding.value.param, e)
        }

        // Add Event listeners
        el.addEventListener("mousedown", start);
        el.addEventListener("touchstart", start);
        // Cancel timeouts if this events happen
        el.addEventListener("click", cancel);
        el.addEventListener("mouseout", cancel);
        el.addEventListener("touchend", cancel);
        el.addEventListener("touchcancel", cancel);
        el.addEventListener("touchmove", cancel);
    }
})


var v =  new Vue({
    el: '#app',
    data: {
        //改动2
<#list searchList as item>
        search${item.name}:'',
</#list>
        classifyScope:'',
        description: '${tool_description}',

        menuList:[

<#list tables as t>
        {
        label: '${t.nameChinese}',
        table: '${t.pinyinOfEntityName}',
        dbTable: '${t.name}'
        },
</#list>

        ],
        selectTable: '${tables[0].pinyinOfEntityName}',

        loading: true,
        dataList: [],


<#list tables as t>
    ${t.pinyinOfEntityName}: {
    <#list t.columns as c>
        ${c.changedName}: '',
    </#list>
    },
</#list>

    form: {
        },
        superSearchField: [
<#if columns??>
    <#list columns as c>
        <#if c.name != "id">
            <#if c.name?starts_with("column")>
            {
                label: '${c.comment}',
                value: '${c.changedName}',
            },
            <#else >
            {
                label: '${c.formulaName}',
                value: '${c.changedName}',
            },
            </#if>
        </#if>
    </#list>
</#if>
        ],
        oldForm: {},
        searchField: '', // 高级搜索框确定的搜索字段
        openSuperSearch: false,
        formVisible: false,
        formTitle: '',
<#--计算表单label宽度，宽度范围[90px ~ 300px]-->
<#assign max_len = 6>
<#if columns??>
    <#list columns as c>
        <#if (c.comment?? && c.comment?length > max_len) >
            <#assign max_len = c.comment?length>
        </#if>
    </#list>
</#if>
        formLabelWidth: '${[max_len, 20]?min * 18}px',
        fileList:[],
        isMobile: false,
        pageSize: 10,
        page: 1,
        total: 0,
        totalPage: 1,

        uploadDialog: false,
        showUploadBtn: false,
        loadingForLoadMore:false,
        bottomSheet: false,
        selectItem: {},
        mobileDetailDialog: false,
        searchKey: '',
        showResetSearchBtn: false,
        mobileSearchVisible: false,
        refreshing: false
    },
    mounted: function () {
        this.isMobile = window.innerWidth <= mobileWidth;

        this.handleCurrentChange(1);
        this.form = this[this.selectTable]
},
methods: {
<#if n_view_tool>
    handleSelect(key, keyPath) {
        this.selectTable = key
        this.resetSearch()
        this.form = this[this.selectTable]
    },
    handleTab(val){
        this.resetSearch()
        this.form = this[this.selectTable]
    },
    handleAdd: function () {
            this.resetForm();
            this.formTitle = '新增'
            this.formVisible = true
            this.form.action = 'add' + this.selectTable
    },
        handleEdit: function (index, row) {
            this.formTitle = '修改'
            this.formVisible = true
            this.oldForm = JSON.parse(JSON.stringify(row))  //序列化 反序列化 =》 克隆
            this.form = JSON.parse(JSON.stringify(row)) //序列化 反序列化 =》 克隆
            this.form.action = 'edit'+ this.selectTable +'ById'
    },
    //改动3
    //改动4
<#if hasToolControl>
    toolUseClick: function (row) {
    var sendParams= JSON.parse(JSON.stringify(row)) //参数，可传可不传
    //toolid使用插值语法传入
    var url = 'https://www.wetoband.com/tre//runToolWithToolShopToolID?toolID=${toolControlId}&bandID=' + bandID + '&gid=' + bandID + '&param=';
    window.open(url);
    },
</#if>
    //改动2
    handleClassifyClick: function (val) {
    console.log("111"+val)
    var _this = this;
    this.loading = true;
    //确定当前分类取值
    this.classifyScope=val;
    axios
    .get(fyToolUrl, {
    params: {
    action: 'getPage'+ this.selectTable,
    page:_this.page,
    pageSize: _this.pageSize,
    classifyButtonValue:val
    }
    })
    .then(function (response) {
    _this.loading = false;
    _this.refreshing = false;
    if(!response.data.rows){
    return;
    }
    _this.total = response.data.total;
    _this.totalPage = response.data.totalPage;
    _this.dataList = response.data.rows;
    })
    .catch(function (error) { // 请求失败处理
    console.log(error);
    _this.loading = false;
    _this.refreshing = false;
    _this.$message("分类展示失败");
    });
    },
    searchByItem: function () {
    var _this = this;
    this.loading = true;
    axios
    .get(fyToolUrl, {
    params: {
    action: 'getPage'+ this.selectTable,
    //这里应该在模板里循环生成key哦
    <#list searchList as item>
    searchKey${item.name}:_this.search${item.name},
    </#list>
    page: _this.page,
    pageSize: _this.pageSize,
    //打开注释可以在当前分类下搜索
    //classifyButtonValue: _this.classifyScope
    }
    })
    .then(function (response) {
    _this.loading = false;
    _this.refreshing = false;
    if(!response.data.rows){
    return;
    }
    _this.total = response.data.total;
    _this.totalPage = response.data.totalPage;
    _this.dataList = response.data.rows;
    })
    .catch(function (error) { // 请求失败处理
    console.log(error);
    _this.loading = false;
    _this.refreshing = false;
    _this.$message("搜索失败");
    });
    },
    //改动
    handleView: function (index, row) {
    this.formTitle = '查看'
    this.formVisible = true
    },
        handleDelete: function (index, row) {
            var _this = this;
            this.$confirm('确定删除?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                customClass:_this.isMobile ? 'msgBox' : '',
                type: 'warning'
            }).then(function () {
                _this.form.id = row.id
                _this.form.action = 'delete'+ _this.selectTable +'ById'
                _this.postForm()
            });
        },
        handleMobileDelete: function(id){
            var _this = this;
            this.$confirm('确定删除?', '提示', {
                confirmButtonText: '确定',
                cancelButtonText: '取消',
                customClass:_this.isMobile ? 'msgBox' : '',
                type: 'warning'
            }).then(function () {

    var url = fyToolUrl + "&returnType=VALUE&action=delete"+ _this.selectTable  +"ById&id=" + id;
                axios.get(url)
                    .then(function (response) {
                        if (response.data.result) {
                            for (var i in _this.dataList){
                                if (_this.dataList[i].id == id) {
                                    _this.dataList.splice(i,1)
                                }
                            }

                        }
                        _this.$message(response.data.msg)
                    }).catch(function () { // 请求失败处理
                });
            });
        },
        commitForm: function () {
<#if columns??>
    <#list columns as c>
        <#if c.name != 'id' && !c.name?starts_with("column")>
            let ${c.changedName} = "${c.comment}";
            <#assign x=1>
            <#list columns as c1>
                <#if c1.changedName?starts_with("column")>
                    <#assign a="a${x}">
            ${c.changedName} = ${c.changedName}.replace(/${a}/gi, this.form.${c1.changedName});
                    <#assign x++>
                </#if>
            </#list>
            try {
                this.form.${c.changedName} = eval(${c.changedName});
            } catch (e) {
                this.form.${c.changedName} = "出错！error";
            }

        </#if>
    </#list>
</#if>
            this.postForm()
            this.formVisible = false
        },
</#if>
        refresh: function () {
            this.refreshing = true;
            this.resetPage();
            this.handleCurrentChange(1);
        },
        postForm: function () {
            var that = this
            $.post(fyToolUrl, that.form, function (res) {
                if (res.result) {
                    that.handleCurrentChange(that.page);
                    that.resetForm()
                }
                that.$message(res.msg)
            })
        },
        resetForm: function () {
            Object.keys(this.form).forEach(k => this.form[k] = '')
        },
        handleClose: function (done) {
            var that = this
            for (var key in this.oldForm) {
                if (that.oldForm.hasOwnProperty(key)) {
                    that.form[key] = that.oldForm[key]
                }
            }
            done()
        },
        submitUpload: function() {
            this.$refs.upload.submit();
        },
        handleRemove: function(file, fileList) {
            this.showUploadBtn = fileList.length > 0;
        },
        handleChange: function(file, fileList) {
            this.showUploadBtn = fileList.length > 0;
        },
        handleUploadSuccess: function(data){
            var _this = this;

            if (data.result){
                this.$message(data.msg);
                this.$refs.upload.clearFiles();
                this.handleCurrentChange(this.page);
                this.uploadDialog = false;
            } else{
                this.$alert(data.msg, '错误', {
                    confirmButtonText: '确定',
                    customClass:_this.isMobile ? 'msgBox' : '',
                    dangerouslyUseHTMLString: true
                });
            }
        },
        resetFile: function(){
            this.$refs.upload.clearFiles();
            this.showUploadBtn = false;
        },
          handleSizeChange: function(val){
            this.pageSize = val;
            this.handleCurrentChange(1);
        },
        handleCurrentChange: function(val){
            if(this.showResetSearchBtn){
                this.search(val);
                return;
            }

            this.page = val;
            var url = fyToolUrl + "&returnType=VALUE&action=getPage"+ this.selectTable +"&page=" + val + "&pageSize=" + this.pageSize;
            var _this = this;
            this.loading = true;
            axios
                .get(url)
                .then(function (response) {
                    _this.loading = false;
                    _this.refreshing = false;

                    if(!response.data.rows){
                        return;
                    }

                    _this.total = response.data.total;
                    _this.totalPage = response.data.totalPage;
                    _this.dataList = response.data.rows;

                })
                .catch(function (error) { // 请求失败处理
                    console.log(error);
                    _this.loading = false;
                    _this.refreshing = false;
                });
        },
        clickRow: function(row){
            this.$refs.table.toggleRowExpansion(row)
        },
        getSubStringWhenTooLong: function(val){
            if(!val){
                return '';
            }
            return this.isMobile && val.length > 10 ? val.substring(0,10) + "..." : val;
        },
        loadMore: function(){
            if (!this.isMobile) {
                return;
            }
            if (this.page >= this.totalPage) {
                return
            }

            this.loadingForLoadMore = true;
            this.page++;

            if(this.mobileSearchVisible){
                this.search(this.page);
                return;
            }

            var url = fyToolUrl + "&returnType=VALUE&action=getPage"+ this.selectTable +"&page=" + this.page + "&pageSize=" + this.pageSize;
            var _this = this;
            axios
                .get(url)
                .then(function (response) {
                    _this.total = response.data.total;
                    _this.totalPage = response.data.totalPage;
                    _this.loadingForLoadMore = false;
                    if (response.data.rows.length > 0) {
                        for (var i in response.data.rows) {
                            _this.dataList.push(response.data.rows[i]);
                        }
                    }
                }).catch(function () { // 请求失败处理
                    _this.loadingForLoadMore = false;
                });
        },
        longTap: function(row){
            this.selectItem = row;
            this.bottomSheet = true;
            this.vibrate([50]);
        },
        viewDetail: function(row){
            this.mobileDetailDialog = true;
            this.selectItem = row;
        },
        search: function(page, scope = "all"){
            // 如果没有选择下拉框，默认全搜索
            if(!scope) {
                scope = "all";
            }
            if (!this.searchKey){
                this.$message("请输入搜索参数");
                return;
            }

            var _this = this;
            this.loading = true;
            axios
                .get(fyToolUrl, {
                    params: {
                        action: 'getPage'+ this.selectTable,
                        key: _this.searchKey,
                        page: page,
                        pageSize: _this.pageSize,
                        scope: scope
                    }
                })
                .then(function (response) {
                    if (!!response.data.rows){
                        _this.page = page;
                        _this.total = response.data.total;

                        if(_this.mobileSearchVisible){
                            if (page === 1){
                                _this.dataList = [];
                            }
                            if (response.data.rows.length > 0) {
                                for (var i in response.data.rows) {
                                    _this.dataList.push(response.data.rows[i]);
                                }
                            }
                        }else{
                            _this.dataList = response.data.rows;
                            _this.showResetSearchBtn = true;
                        }
                    }else{
                        _this.$message("搜索失败");
                    }
                    _this.loading = false;
                    _this.loadingForLoadMore = false;
                })
                .catch(function (error) { // 请求失败处理
                    console.log(error);
                    _this.loading = false
                    _this.$message("搜索失败");
                });

        },
        resetSearch: function(){
            this.mobileSearchVisible = false;
            this.searchKey = '';
            this.showResetSearchBtn = false;
            this.resetPage();
            this.handleCurrentChange(1);
        },
        resetPage: function(){
            this.pageSize= 10;
            this.page= 1;
            this.total= 0;
        },
        downloadExcelModel: function(){
            var table = this.getDbTable(this.selectTable)
            var url =  fyToolUrl + '&action=downloadExcelModel&table=' + table.dbTable + "&tableName=" + table.label;
            window.location = url
        },
        downloadExcelData: function () {

            window.location = fyToolUrl + '&action=downloadExcelData' + this.selectTable;
        },
        vibrate: function (milliseconds) {
            if ('vibrate' in window.navigator) {
                window.navigator.vibrate(milliseconds); // 震动200停100再震动200，和qq的消息震动一样
            } else {
                console.log("浏览器不支持震动")
            }
        },

getDbTable: function (table) {
for (var i in this.menuList) {
if (this.menuList[i].table == table){
return this.menuList[i];
}
}
}
},
computed:{
uploadUrl: function(){
return fyToolUrl + "&returnType=VALUE&action=importDataFromExcel&table=" + this.getDbTable(this.selectTable).dbTable;
        },
        labelPosition:function(){
            return this.isMobile ? 'top' : 'right';
        },
        dialogWidth:function(){
            return this.isMobile ? '90%' : '50%';
        },
        paginationLayout:function () {
            return this.isMobile ? 'prev, pager, next' : 'total, sizes, prev, pager, next, jumper';
        },
        updateDescription: function() {
            this.description = this.description.trim();
            if(this.isMobile) {
                return this.description.length > 10 ? this.description.substr(0,10) : this.description;
            } else {
                return this.description.length > 30 ? this.description.substr(0,30) : this.description;
            }
        },

    }
})

window.onresize = function () {
//改动
v.isMobile = false;
}