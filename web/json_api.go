package main

import (
	"fmt"
	"net/http"
	"log"
	"io/ioutil"
	"os"
	"strings"
	"encoding/json"
)
type DB struct{
    ip string
    user string
    password string
    }



func main(){
	domain_name:="http://95.216.164.197"

	file,err:=os.Open("web/request.sql")
        if err != nil{
                log.Fatal(err)
        }
	b,err :=ioutil.ReadAll(file)
	defer file.Close()
	if err != nil{
		log.Fatal(err)
	}
	file,err=os.Open("configs/clickhouse_host.json")
    if err !=nil{log.Fatal(err)}
	json_db,err :=ioutil.ReadAll(file)
	defer file.Close()
    file,err=os.Open("configs/my_json_api_key.txt")
    if err !=nil{log.Fatal(err)}
    my_api_key,err:=ioutil.ReadAll(file)
    if err !=nil{log.Fatal(err)}
    defer file.Close()

	var db DB
	json.Unmarshal(json_db,&db)
	req:=string(b)
	req= strings.ReplaceAll(req,"\n","%20")
	req=strings.ReplaceAll(req,"\t","%20")
	req=strings.ReplaceAll(req," ","%20")
	req="http://"+db.ip+":8123?query="+req
	http.HandleFunc("/",func(w http.ResponseWriter, r *http.Request){
	method := r.URL.Path[len("/pa/json-api/"):]
	url := r.URL.Path

    switch method {
		case "now":
		    file,err = os.Open("/tmp/cached_pa_data.json")
            if(err !=nil){
                fmt.Fprintf(w,"Please,wait new data will be soon received.")
                return}
            defer file.Close()
            content,err:=ioutil.ReadAll(file)
            if(err !=nil){log.Fatal(err)}
            body := string(content)
			w.Header().Set("Content-Type","application/json")
			//fmt.Fprintf(w,"%s",db.ip)
			fmt.Fprintf(w,"%s",body)
		case "telemetry":
			from:=r.URL.Query().Get("from")
			to :=r.URL.Query().Get("to")
                        w.Header().Set("Content-Type","application/json")
			api_key := r.URL.Query().Get("key")
            if(string(my_api_key[:len(my_api_key)-1])==api_key){ 
            if(len(from)<1 || len(to)<1 || len(to)!=14 || len(from)!=14){
				http.Redirect(w,r,url[:len(url)-len(method)]+"/help?"+"err=Time%20parameters%20not%20found%20or%20they%20are%20bad", 301)
			}else{
				from = from[:4] +"-"+from[4:6]+"-"+from[6:8]+"-"+from[8:10]+":"+from[10:12]+":"+from[12:14]
				to = to[:4] +"-"+to[4:6]+"-"+to[6:8]+"-"+to[8:10]+":"+to[10:12]+":"+to[12:14]
				req_str := req + "WHERE%20(Timestamp%20>=%20toDateTime(%27"+from+"%27)%20AND%20Timestamp<=%20toDateTime(%27"+to+"%27))%20ORDER%20BY%20Timestamp,sensor_id%20DESC%20%20FORMAT%20JSON"
				//fmt.Fprintf(w,"%s",req_str)
				resp,err:=http.Get(req_str)
                        if(err !=nil){
                                log.Fatalln(err)
                        }
                        defer resp.Body.Close()
                        contents,err:=ioutil.ReadAll(resp.Body)
                        if err != nil{
                                log.Fatalln(err)
                        }
                        body := string(contents)
			fmt.Fprintf(w,"%s",body)
			}
            }
		case "help":
			w.Header().Set("Content-Type","text/html")
			mistake:=r.URL.Query().Get("err")
			file,err:=os.Open("web/help.html")
			if err != nil{
				log.Fatal(err)
			}else{
				defer file.Close()
				b,err:=ioutil.ReadAll(file)
				if err!= nil{
					log.Fatal(err)
				}
				help_str :=strings.ReplaceAll(string(b),"[domain]",domain_name)
				if(len(mistake)>1){
					fmt.Fprintf(w,"Error: %s<br>",mistake)
				}
				fmt.Fprintf(w,"%s",help_str)
			}
		default:
			http.Redirect(w,r,url[:len(url)-len(method)]+"/help?"+"err=No%20such%20api%20method%20%27"+method+"%27",301)
		}
	})

	http.ListenAndServe(":9990",nil)

}
