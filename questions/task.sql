insert into t1 values(1,NULL);
insert into t1 values(1,2);
insert into t1 values(2,2);
insert into t1 values(3,2);
insert into t1 values(4,1);

select * from t1 

insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;
insert into t1 select * from t1;

alter table t1 add column a char(500);
alter table t1 add column b char(500);
alter table t1 add column c char(500);
alter table t1 add column d char(500);
alter table t1 add column e char(500);
alter table t1 add column f char(500);
alter table t1 add column g char(500);
alter table t1 add column h char(500);
alter table t1 add column i char(500);
alter table t1 add column j char(500);
alter table t1 add column k char(500);
alter table t1 add column l char(500);


update t1 set a = 'some long string that should be 500 chars',
b = 'some long string that should be 500 chars',
c = 'some long string that should be 500 chars',
d = 'some long string that should be 500 chars',
e = 'some long string that should be 500 chars',
f = 'some long string that should be 500 chars';

update t1 set g = 'some long string that should be 500 chars',
h = 'some long string that should be 500 chars',
i = 'some long string that should be 500 chars',
j = 'some long string that should be 500 chars',
k = 'some long string that should be 500 chars',
l = 'some long string that should be 500 chars'

create or replace index idx_t1_x on t1(x);

select count(*) from t1

select a.x from t1 a join t1 b on a.x=b.x

create table t2(x int)

select a.x from t1 a join t2 b on a.x=b.x

explain analyze select * from t2
