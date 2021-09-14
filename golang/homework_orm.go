// install package
// go get github.com/astaxie/beego/orm
// go get github.com/go-sql-driver/mysql

package main
import (
    _ "beego_dev_model/routers"
    "github.com/astaxie/beego"
    "github.com/astaxie/beego/orm"
    _ "github.com/go-sql-driver/mysql" 
)

//初始化mysql连接
func init() {
	dev_username := beego.AppConfig.String("dev_username")
	dev_userpwd := beego.AppConfig.String("dev_userpwd")
	dev_dbhost := beego.AppConfig.String("dev_dbhost")
    dev_dbport := beego.AppConfig.String("dev_dbport")
    devdbname := beego.AppConfig.String("devdbname")
	devdb_data_source := dev_username + ":" + dev_userpwd + "@tcp(" + dev_dbhost ":" + dev_dbport + ")/" + devdbname + "?charset=uft8"

	test_username := beego.AppConfig.String("test_username")
	test_userpwd := beego.AppConfig.String("test_userpwd")
	test_dbhost := beego.AppConfig.String("test_dbhost")
	test_dbport := beego.AppConfig.String("test_dbport")
	testdbname := beego.AppConfig.String("testdbname")
	testdb_data_source := test_username + ":" + test_userpwd + "@tcp(" + test_dbhost + ":" + test_dbport + ")/" + testdbname + "?charset=utf8"

	orm.RegisterDriver("mysql", orm.DRMySQL)

	orm.RegisterDataBase("devdb", "mysql", devdb_data_source, 30)
	orm.RegisterDataBase("testdb", "mysql", testdb_data_source, 30)
}

