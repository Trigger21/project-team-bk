# R 크롤링 하는법

#install.packages("rvest")
library(rvest)
library(dplyr)
library(stringr)

# 선블록
html<- read_html("https://www.glowpick.com/category_product?id=3")

# 제품군 내 1~3위 total
total <- html_nodes(html,css = "#category1 > div > div > a > span")%>% 
  html_text()
total<- strsplit(total,"\n")

total<- unlist(total)
total<- str_trim(total)

total <- grep("[[:alpha:]]|[[:digit:]]",total,value = T)
total   #1번 메이커 , 2번 제품명, 3번 가격, 4번 평점

#메이커,제품명,가격,평점별로 나누기
maker1<- total[c(1,5,9)]
title1<- total[c(2,6,10)]
price1<- total[c(3,7,11)]
star1<- total[c(4,8,12)]

# 제품군 내 4~10위 메이커
maker2 <- html_nodes(html,css = "#category1 > div > div.hidden-xs.pcList > div > div > div.item3 > a > h5")%>% 
  html_text()
maker2

# 제품군 내 4~10위 제품명
title2 <- html_nodes(html,css = "#category1 > div > div.hidden-xs.pcList > div > div > div.item3 > a > p")%>% 
  html_text()
title2

# 제품군 내 4~10위 가격
price2 <- html_nodes(html,css = "#category1 > div > div.hidden-xs.pcList > div > div > div.item4")%>% 
  html_text()
price2<- gsub("\n","",price2)
price2<- str_trim(price2)

# 제품군 내 4~10위 평점
star2 <- html_nodes(html,css = "#category1 > div > div.hidden-xs.pcList > div > div > div.item5")%>% 
  html_text()
star2<- gsub("\n","",star2)
star2<- gsub("점","",star2)
star2<- str_trim(star2)
star2<- unlist(strsplit(star2,'/'))
star2<- star2[c(1,3,5,7,9,11,13)]
star2

#통합
maker<- append(maker1,maker2)
title<- append(title1,title2)
price<- append(price1, price2)
star<- append(star1,star2)

maker
title
price
star


# 제품군 내 1~3위 뒷링크
url1 <- html_nodes(html,"#category1 > div > div > a")%>%
  html_attr('href')
url1

# 제품군 내 4~10위 뒷링크
url2 <- html_nodes(html,".item3Link" )%>% 
  html_attr("href")
url2

url<- append(url1,url2)

text <- c()
id <- c()
for(j in 1:10){
  
  html2 <- read_html(paste0("https://www.glowpick.com",url)[j])
  html2
  
  for(i in 1:20){
    id1<- html_node(html2, paste0("#reviewList > ul > li:nth-child(",i,") > div:nth-child(2) > div > div.reviewerInfo > div:nth-child(1)"))%>%
      html_text() 
    id<- c(id,id1)
    
    text1<- html_node(html2, paste0("#reviewList > ul > li:nth-child(",i,") > div:nth-child(2) > div > p"))%>%
      html_text() 
    text<- c(text,text1)
  }
}

#통합
text
id

#id 안에 있던 정보를 name, age, skin_type 로 나누는 작업
name<- c()
a<- c()
for(i in 1:length(id)){
  name<- c(name,str_split(id, " ")[[i]][1])
  a<- c(a,str_split(id, " ")[[i]][2])
}



age<- c()
type<- c()
for(i in 1:length(id)){
  age<- c(age,str_split(a, "/")[[i]][1])
  type<- c(type,str_split(a, "/")[[i]][2])
}

age<- gsub('\\(',"",age)
age<- gsub('세',"",age)
type<- gsub("\\)","",type)

age
name
type

maker
title
price
star

#text 주변 정리
text<- gsub("\\\r"," ",text)
text<- gsub("\\\n"," ",text)
text<- str_trim(text)
text

review <- data.frame(maker = rep(maker,20), title = rep(title,20), price = rep(price,20), star = rep(star, 20), text = text, age = age, skin_type = type, name = name,stringsAsFactors = F)
str(review)
levels(review[,'maker'])<- maker
review[,'maker']<-sort(review[,'maker'])

levels(review[,'title'])<- title
review[,'title']<-sort(review[,'title'])

levels(review[,'price'])<- price
review[,'price']<-sort(review[,'price'])

levels(review[,'star'])<- star
review[,'star']<-sort(review[,'star'])

review

write.csv(review,"c:/r/review_project")

unlist(text)

text1<- SimplePos09(unlist(text))

text1<-unlist(str_match_all(text1, '([A-Z가-힣]+)/N'))

text1<-text1[!str_detect(text1, '/')]

text2<- sort(table(text1),decreasing = T)

text1

text5<- text2[nchar(names(text2))>1]
text5

wordcloud2(text5,size = 2)



#심플포스 안쓰고 띄워쓰기 기준으로 단어 분해
unlist(text)

test1 <- strsplit(unlist(text),split=" ")

test2 <- unlist(test1)
test2
td<- data.frame(name=a,cnt = length(a),stringsAsFactors = F)


a<- read.table("c:/r/aaa4.txt",stringsAsFactors = F)
a<- a$V1
a<- unique(a)
a


for(i in a){
  td$cnt[td$name==i]<- length(test2[grep(i,test2,ignore.case = TRUE)])
}

td


#조립 qwe 하고 td
text6<- text5[text5<=5]

qwe<- data.frame(text6)
names(qwe)<- names(td)
head(qwe)
  td$cnt 
text7 <- merge(td,qwe,all=T)

wordcloud2(text7,size=2)


#20대 리뷰 따로 빼기
review$age<- as.numeric(review$age)
review[review$age> 20&review$age < 30,]

text_20<- review[review$age> 20&review$age < 30,"text"]

#심플포스 안쓰고 띄워쓰기 기준으로 단어 분해
unlist(text_20)

test1 <- strsplit(unlist(text_20),split=" ")

test2 <- unlist(test1)

a<- read.table("c:/r/aaa4.txt",stringsAsFactors = F)
a<- a$V1
a<- unique(a)
a

td_20<- data.frame(name=a,cnt = length(a),stringsAsFactors = F)


for(i in a){
  td_20$cnt[td$name==i]<- length(test2[grep(i,test2,ignore.case = TRUE)])
}

td_20

wordcloud2(td_20)


#조립 qwe 하고 td
text6<- text5[text5<=5]

qwe<- data.frame(text6)
names(qwe)<- names(td)
head(qwe)
td$cnt 
text7 <- merge(td,qwe,all=T)

wordcloud2(text7)

ggplot(td_c30,aes(x=name,y=cnt))+
  geom_bar(stat = "identity",fill = rainbow(length(td_c20$name)))+
  labs(title = '30대 주요 키워드',x='키워드',y='횟수')+
  theme(plot.title=element_text(face='bold', color='darkblue',hjust=0.5))+
  theme(axis.text.x=element_text(angle=45,hjust=1,vjust=1,colour="blue",size=7))+
  theme(axis.text.y=element_text(face='bold.italic',color="brown",size=10))

pal <- brewer.pal(20,"Set3")

ggplot(td_12,aes(x=reorder(name, +cnt),y=cnt))+
  geom_bar(stat = "identity",fill = rainbow_hcl(20))+
  labs(title = '30대 주요 키워드',x='키워드',y='횟수')+
  theme(plot.title=element_text(face='bold', color='darkblue',hjust=0.5))+
  coord_flip()+
  theme(axis.text.y=element_text(hjust=1,vjust=1,colour="darkblue",size=10))+
  theme(axis.text.x=element_text(face='bold.italic',color="brown",size=10))


#30대 리뷰 따로 빼기
review$age<- as.numeric(review$age)
review[review$age> 30,]

text_30<- review[review$age> 30,"text"]

#심플포스 안쓰고 띄워쓰기 기준으로 단어 분해
unlist(text_30)

test1 <- strsplit(unlist(text_30),split=" ")

test2 <- unlist(test1)

a<- read.table("c:/r/aaa4.txt",stringsAsFactors = F)
a<- a$V1
a<- unique(a)
a

td_30<- data.frame(name=a,cnt = length(a),stringsAsFactors = F)


for(i in a){
  td_30$cnt[td$name==i]<- length(test2[grep(i,test2,ignore.case = TRUE)])
}

td_30

wordcloud2(td_30)


#조립 qwe 하고 td
text6<- text5[text5<=5]

qwe<- data.frame(text6)
names(qwe)<- names(td)
head(qwe)
td$cnt 
text7 <- merge(td,qwe,all=T)

wordcloud2(text7)









wordcloud2(td)

test3<- sort(table(test2),decreasing = T)

head(test3,50)

wordcloud2(test3)

p <- read.csv("c:/r/review_project.csv")
p


a<- read.table("c:/r/aaa3.txt",stringsAsFactors = F)
a<- a$V1
a<- unique(a)
a

b<- c(rep(0,length(a)))
c<- c()
for(i in 1:length(text)){
  c<- str_count(text[i],ignore.case(a))
  b<- b+c
}

ttt<- data.frame(name= a, cnt = b)
ttt
wordcloud2(ttt)

ttt3<- data.frame(name=a,cnt = length(a),stringsAsFactors = F)
for(i in a){
  ttt$cnt[ttt$name==i]<- length(t4[grep(i,t4,ignore.case = TRUE)])
}
table(ttt)
ttt2<- data.frame(cnt = b)
rownames(ttt2)<- a

useSejongDic()
write(a,'c:/r/aaa4.txt')
buildDictionary(ext_dic="sejong",user_dic=data.frame(read.lines("c:/r/aaa4.txt"),"ncn"),replace_usr_dic=T)
help("read.lines")
'??read.lines'
mergeUserDic(data.frame(a,"ncn"))

data = sapply(text,extractNoun,USE.NAMES = F)
data1<- unlist(data)
data2<- Filter(function(x){nchar(x)>=2},data1)
data2
t_data<- table(data2)
wordcloud2(t_data,shape = "star")
