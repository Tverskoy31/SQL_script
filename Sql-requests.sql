-- Формы записи SELECT

select name as "Стадион",
size as "Вместимость"
from arena; 
------------------------
select name as "ФИО",
position as "Позиция",
salary as "Зарплата"
from player;
--------------------------
select name as "ФИО",
	height as "Рост",
	weight  as "Вес"
from player;
--------------------------------------

-- Формы записи WHERE
where size > 9000;
where position = 'форвард' or position = 'защитник';
where (position = 'форвард' or position = 'защитник') and salary between 240000 and 260000;
where height > 215 or weight > 120;
where (city = 'Барселона' or city = 'Москва') and coach_name = 'Димитрис Итудис';
where height between 188 and 200 and salary between 100000 and 150000;
where height between 188 and 200 and position in ('центровой','защитник')
where id in (10,30,50) --идентификатор должен быть выбран из списка 10, 30, 50. 

-- Формы записи сортировки
Order by name;
Order by name desc;
Order by size,name;
order by position,name desc;

-- Запрос возвращает данные по игровым командам в виде (один столбец со всеми данными внутри) с сортировкой по полю “полная информация”, конкатенация.

select 'город:'||' '|| city ||'; '|| 'команда:'||' '||name ||'; '|| 'тренер:'||' '||coach_name as "Полная информация"
from team
order by city,
name, 
coach_name; 

--Ограничить вывод данных до 5 строк
limit 5;

-- Запрос возвращает имена стадионов и имена команд в одном списке. Результат отсортирован в убывающем порядке.

sselect name from arena
union all
select name from team
order by 1 desc;

/* Запрос возвращает имена стадионов и имена команд в одном списке, но с типом что запись является или “стадион” или “команда”.
 Результат отсортирован в убывающем порядке по типу записи и потом по имени. */

select name, 
'Стадион' as object_type
from arena
union all
select name,
'Команда' as object_type
from team
order by object_type desc, name;
     
      
-- Запрос который возвращает имена и зарплаты игроков в отсортированном списке по зарплатам в возрастающем порядке, НО зарплата со значением 475 000 должна быть на первом месте. 


select name,
salary
from player
order by
case when salary = 475000 then '1'
else salary
end
limit 5;

  

-- Задание 4d: 

insert into team 
(id,city,name,coach_name,arena_id)
values (60,'Москва','СКА','Петр Иванов',30);



-- Задание 4e:

(
(select id from arena)
except
(select id from game)
)
UNION
(
(select id from game)
except
(select id from arena)
)
order by 1;



/* Выведите имена игроков, название команды и соответствующего стадиона одним SQL запросом. 
 Результат отсортируйте по имени игрока и названию команды.*/

select p.name as "player_name",
		t.name as "team_name",
		a.name as "arena_name"
	from player as p
		inner join 
		team as t on t.id = p.team_id
		inner join 
		arena as a on a.id = t.arena_id
	order by p.name, 
			t.name; 
		
			
/* Запрос который вернет список городов, играющих команд и название домашней арены , вместимость которой строго больше чем 10000 мест. 
Результат отсортируйте по названию города в убывающем порядке.*/

select t.city as city_name,
t.name as team_name,
a.name as arena_name
from team as t
inner join arena as a on t.arena_id = a.id
where a."size" > 10000
order by city_name desc


/* Запрос который возвращает информацию по играм между командами с указанием имени команды хозяина, имени гостевой команды, имени команды победителя, 
финальный счет и название стадиона на котором проводилась игра. 
Результат отсортируйте по имени команды хозяина и по имени гостевой команды.*/

select t."name" as owner_team,
t2."name" as guest_team,
t3."name" as winner_team,
g.score,
a."name" as arena_name
from game as g
inner join team as t
on g.owner_team_id = t.id
inner join team as t2
on g.guest_team_id = t2.id
inner join team as t3
on g.winner_team_id = t3.id
inner join arena as a
on g.arena_id = a.id
order by owner_team, 
        guest_team

	
/* Запрос который возвращает имена ВСЕХ стадионов и соответствующую дату игры на стадионе. Если стадион не участвовал в играх - необходимо вывести значение “игра не проводилась”. 
Результат отсортирован по двум столбцам.*/

select a.name as arena_name,
case
when g.game_date is null then 'игра не проводилась'::varchar
else g.game_date ::varchar
end
from arena as a
left join game as g
on g.arena_id = a.id
order by 1, 2


/* Запрос который возвращает имена команд из одного города. Отсортируйте результат по имени команды.*/
		
with msk as (select city, count(*)
from team
group by city
having count(*) > 1)
select name as team_name,
city
from team
where city in (select city from msk)
order by team_name
	
		
/* 2 SQL запроса возвращающие стадионы которые были использованы как арены для проведения игр , используя SQL команды IN и EXISTS. 
Результат отсортируйте по имени стадиона.*/

select name
from arena
where id in (select arena_id
from game)
order by name


select name
from arena as a
where exists 
(select * from game as g
where g.arena_id = a.id)
order by name
	

/* Перепишите запрос из задачи a) с учетом использования CTE выражения (Common Table Expression) . Вынесите в CTE часть SQL запроса по стадионам с фильтрацией по количеству мест строго больше 10000. 
Результат запроса должен полностью совпадать с результатом задачи a) (другими словами выполняется семантическая эквивалентность).  */

with bro as (select id
from arena
where size > 10000)
select t.city as city_name,
t.name as team_name,
a.name as arena_name
from team as t inner join arena as a
on t.arena_id = a.id and a.id in (select id from bro)
order by city_name desc


-- Вывод min,max и среднего значения

select avg(height) as avg_height, 
	min(height) as min_height, 
	max(height) as max_height,
	sum(salary) as total_salary
	from player; 

/* Перепишите SQL запрос из пункта a) в разрезе группировки данных по позиции игрока на игровом поле. Результат отсортируйте по позиции игрока.
 Округление по среднему росту сделайте до 2 знаков после запятой. */
		
select position, 
round(avg(height),2) as avg_height, 
min(height) as min_height, 
max(height) as max_height,
sum(salary) as total_salary
from player 
group by position 
order by position;
	

/*Запрос который возвращает количество побед команд. Результат отсортируйте в убывающем списке по количеству побед.*/

select name,
count(game.winner_team_id) as count_wins
from team,game where (game.winner_team_id=team.id)
group by name
order by count_wins DESC;


/* Запрос который возвращает города, встречающиеся  более чем один раз, используя конструкцию GROUP BY.*/

select city from team
group by city having count(city)>1

		

/*Запрос который возвращает информацию по играм между командами с указанием имени команды хозяина, имени гостевой команды , имени команды победителя и номера строки возвращаемого набора данных. 
Результат отсортируйте по имени команды хозяина и по имени гостевой команды. */

select row_number() over(order by o.name,q.name,w.name) as rownum,
o.name as owner_team,
q.name as guest_team,
w.name as winner_team
from game as a
inner join team as o
on a.owner_team_id=o.id
inner join team as q
on a.guest_team_id=q.id
inner join team as w
on a.winner_team_id=w.id
order by owner_team, guest_team
	

/* Запрос который возвращает количество игроков, сгруппированных по классу роста игрока. Результат отсортируйте по классу игрока. Формула распределения по классам представлена ниже как псевдокод.
-ЕСЛИ рост < 190 ТОГДА 1
-ЕСЛИ рост >= 190 И рост < 200 ТОГДА 2
-В ОСТАЛЬНЫХ СЛУЧАЯХ 3 */

select case
when height<190 then 1
when height>=190 and height<200 then 2
else 3
end height_class,
count(*) as ammount_players
from player
group by height_class
order by height_class


/* Видоизмените SQL запрос из задания a), получив дополнительно строку по общему количеству игроков из каждого класса. 
Отсортируйте результат по классу игрока и NULL значения должны быть в начале списка.*/
select to_number(null,null) as height_class, 
(select count(*) as ammount_player from player) from player 
union 
select case
when height<190 then 1
when height>=190 and height<200 then 2
else 3
end height_class,
count(*) as ammount_players
from player
group by height_class
order by height_class nulls first



/* Выведите одним SQL запросом агрегированные данные по позиции игрока и его команде, получив информацию в следующих срезах
-	количество игроков играющих на определенной позиции в каждой из команд
-	количество игроков играющих на одной позиции на площадке
-	общее количество игроков
-	номер внутренней группы агрегации по игрокам (функция GROUPING … )

Результат отсортируйте по номеру внутренней группы, наименованию
позиции игрока и имени команды.*/

Select pl.position,
t.name as team_name, 
count(pl.id) as ammount_players, 
grouping(pl.position, t.name) as group
From player pl join team t on pl.team_id=t.id
group by
Grouping sets(
(pl.position, t.name),
(pl.position),
()
)
order by grouping(pl.position, t.name),pl.position,t.name



--Выведите при помощи SQL запроса ранжированные зарплаты всех защитников из всех команд. Результат отсортируйте по ранжированному значению и затем по имени игрока.
select dense_rank() over(order by salary) as ranking,
name,
salary from player
where (position='защитник')
order by ranking,name


--Создание и заполнение таблицы

CREATE TABLE users
(id serial primary KEY,
 name varchar(50),
 surname varchar(50),
 middle_name varchar(50),
 telephone bigint,
 email varchar(50),
 pasport_serries bigint,
 pasport_number bigint
 );

INSERT INTO users(name,surname,middle_name,telephone,email,pasport_serries, pasport_number) 
values ('Sergei', 'Ivanov', 'Ivanovich',89001231111,'ivanov@mail.ru',7326,898523);

INSERT INTO users(name,surname,middle_name,telephone,email,pasport_serries, pasport_number) 
values ('Anton', 'Pavlov', 'Mihailovich',89011231232,'antom@yandex.ru',8652,998452);

INSERT INTO users(name,surname,middle_name,telephone,email,pasport_serries, pasport_number) 
values ('Angelina', 'Berezina', 'Pavlovna',89025649881,'angelina@gmail.com',2342,586842);

INSERT INTO users(name,surname,middle_name,telephone,email,pasport_serries, pasport_number) 
values ('Kristina', 'Semenova', 'Victorovna',89034645546,'kris@mail.ru',6545,898652);

INSERT INTO users(name,surname,middle_name,telephone,email,pasport_serries, pasport_number) 
values ('Nikita', 'Stepanov', 'Ivanovich',89046565796,'stepanov@yandex.ru',7665,896545);

		
SELECT * FROM users;	
		
		
/* Задание 9b:	Создайте таблицу (имя укажите сами), описывающую возможность хранить информацию по зависимостям пользователей между друг другом. 
Например, есть пользователь в подчинении которого находятся другие пользователи. В свою очередь другие пользователи возможно имеют своих подчиненных и т.д. 
Другими словами ваша модель должна работать со структурами подчинения такого формата:	
--Где A, B, C, D, E - пользователи

--Создайте 4 произвольных зависимости между существующими пользователями из задания a) и заполните вашу новую таблицу. 
Пожалуйста предоставьте скрин выполнения запроса после создания зависимостей:
--SELECT * FROM <ваша таблица>;
--Пожалуйста на данном этапе не создавайте Внешние Ключи!*/

CREATE TABLE user_depend (
id  serial PRIMARY KEY,
user_id INT,
dep_user_id INT,
type VARCHAR(50)
);
INSERT INTO user_depend  ( user_id, dep_user_id, type) VALUES
(1, 2, 'Pavel'),
(1, 3, 'Kristina'),
(1, 4, 'Anton'),
(3, 5, 'Nikita');
				
		
--Пояснение: в таблице “user_depend” – Anton, Kristina, Nikita находятся в подчинении у Pavel. Nikita также находится в подчинении у Kristina.		

	
 /* Запрос который создаст таблицу с именем “player_defender” содержащую всех игроков с позицией на площадке “защитник” (используйте паттерн “CREATE … AS SELECT …”). */

CREATE TABLE player_defender as
select * from player
where position = 'защитник';


 /* Обновите зарплаты всех игроков в таблице “player_defender” с учетом налогового процента на доход (равный 13%). Другими словами текущая зарплата должна быть за минусом 13%. */

update player_defender 
set salary = salary-(salary/100*13);


/* Удалите игроков из таблицы “player_defender”, чья зарплата меньше 100 000 и вес равный 85 кг. */

delete from  player_defender 
where salary <100000 and weight=85;


/* Запрос который к существующим записям таблицы “player_defender” добавит всех центровых,  НО с учетом налогового процента из задания b). Те зарплата игрока должна соответствовать введенной формуле.*/

insert into player_defender 
select * from player
where position = 'центровой';

update player_defender 
set salary = salary-(salary/100*13)
where position = 'центровой';
