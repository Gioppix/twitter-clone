--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3 (Debian 16.3-1.pgdg120+1)
-- Dumped by pg_dump version 16.3 (Debian 16.3-1.pgdg120+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: comments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comments (
    comment_id integer NOT NULL,
    referenced_post_id integer,
    referenced_comment_id integer,
    text text,
    commenter integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT referenced_post_or_comment CHECK ((((referenced_comment_id IS NULL) AND (referenced_post_id IS NOT NULL)) OR ((referenced_comment_id IS NOT NULL) AND (referenced_post_id IS NULL))))
);


ALTER TABLE public.comments OWNER TO postgres;

--
-- Name: comments_comment_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.comments_comment_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.comments_comment_id_seq OWNER TO postgres;

--
-- Name: comments_comment_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.comments_comment_id_seq OWNED BY public.comments.comment_id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.posts (
    author integer NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    post_id integer NOT NULL,
    CONSTRAINT posts_content_check CHECK ((content <> ''::text))
);


ALTER TABLE public.posts OWNER TO postgres;

--
-- Name: posts_post_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE public.posts ALTER COLUMN post_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME public.posts_post_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    user_id integer NOT NULL,
    session_start timestamp with time zone NOT NULL,
    token text DEFAULT gen_random_uuid() NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    user_id integer NOT NULL,
    username text NOT NULL,
    name text NOT NULL,
    surname text NOT NULL,
    password text NOT NULL,
    is_admin boolean DEFAULT false NOT NULL
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.user_id;


--
-- Name: comments comment_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments ALTER COLUMN comment_id SET DEFAULT nextval('public.comments_comment_id_seq'::regclass);


--
-- Name: users user_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN user_id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: comments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comments (comment_id, referenced_post_id, referenced_comment_id, text, commenter, created_at) FROM stdin;
123	39	\N	Macchina poco efficente	41	2024-07-13 15:45:57.815404+00
124	\N	123	non è vero	42	2024-07-13 15:46:09.748932+00
125	40	\N	1.1	42	2024-07-13 15:46:32.945243+00
126	40	\N	1.2	42	2024-07-13 15:46:35.288998+00
127	40	\N	1.3	42	2024-07-13 15:46:37.14188+00
128	40	\N	1.4	42	2024-07-13 15:46:39.338059+00
129	\N	125	2.1	42	2024-07-13 15:46:44.307337+00
130	\N	125	2.2	42	2024-07-13 15:46:46.747769+00
131	\N	125	2.3	42	2024-07-13 15:46:49.306606+00
132	\N	129	3.1	42	2024-07-13 15:46:52.109291+00
133	\N	129	3.2	42	2024-07-13 15:46:54.306654+00
134	\N	132	4.1	42	2024-07-13 15:46:58.490149+00
135	\N	134	5.1	42	2024-07-13 15:47:01.839603+00
136	\N	135	6.1	42	2024-07-13 15:47:04.634658+00
137	\N	136	7.1	42	2024-07-13 15:47:08.567342+00
138	\N	134	5.2	42	2024-07-13 15:47:17.140456+00
139	\N	134	5.3	42	2024-07-13 15:47:19.613798+00
140	\N	132	4.2	32	2024-07-13 19:02:27.847016+00
141	\N	136	7.2	32	2024-07-13 19:02:39.774142+00
142	\N	136	7.3	32	2024-07-13 19:02:43.686923+00
143	\N	136	7.4	32	2024-07-13 19:02:49.878094+00
144	39	\N	comprala dia	32	2024-07-13 19:04:40.847964+00
145	\N	128	2.1	32	2024-07-13 19:11:08.828121+00
146	\N	145	no way!	32	2024-07-13 19:11:15.168572+00
147	41	\N	It performs a subquery on each iteration until the subquery returns zero rows. If the subquery returns rows those returned rows as placed into a workarea whereby they comprise the contents of the virtual cte table during the next iteration. They are also placed into the final result workarea, which is what gets returned when the CTE is finished being evaluated.  Pass: <virtual cte table> : execution result  Pass 1: <empty> : main query (2 rows) Pass 2: <2 rows> : iteration query (3 rows) Pass 3: <3 rows> : iteration query (1 row) Pass 4: <1 row> : iteration query (0 rows) Done: Returns 6 rows  The iteration query (below the union all) basically uses the virtual cte table as a parent to determine the next set of children, which then themselves becomes parents, etc...  The query above the union initializes the first set of parents.	32	2024-07-13 19:12:29.584183+00
148	\N	147	Thank you!! Now seeing the recursive member as a subquery also helps a lot on seeing the general procedure. Thanks again	32	2024-07-13 19:12:40.834379+00
149	41	\N	Recursion is a tricky concept to understand.  The concept is the same in sql as it is in any other language, so a lecture on recursion in C might help you understand. Berkley and Harvard both have great free online resources in their intro CS courses.  Short version though, a recursive cte acts just like a recursive function. It calls itself, and does something with the output.  I've found it easier to think of recursive functions and CTEs as calling an identical copy of themselves. (Which is what happens behind the scenes - recursion actually takes a little more memory.)  So when your cte references itself, it spawns a new copy of itself scoped for the child object (or parent object, whichever way you've written it to go). Which will in turn call another copy of itself for each child object it finds, and so on until it finds no more child objects or, in the case of sql server, hits the recursion limit (default of 50 levels iirc).  The fundamental difference between recursion and looping is recursion will seamlessly handle branching paths - if your top level object has 5 children, and each of those objects has 5 children, there are 25 independently scoped copies of that query (or function) at n-2, and more importantly it can keep going deeper. Something that is much harder to achieve with loops.	32	2024-07-13 19:12:47.964908+00
150	\N	149	I see, that clarified a lot of things and I’ll definitely check out some lectures in C. Thank you so much	32	2024-07-13 19:12:52.490604+00
151	41	\N	Its really just a way to loop without having to create a WHILE loop.  If you have the book SQL Querying by Itzak Ben-Gan, Itzak will even state its probably a better practice to use a WHILE loop rather than a recursive query.  If you want to know all the different problems recursion can solve, see this GitHub....  https://github.com/smpetersgithub/AdvancedSQLPuzzles/tree/main/Advanced%20SQL%20Puzzles/Recursion%20Examples	32	2024-07-13 19:12:59.569253+00
152	\N	151	Thanks, gonna check this out right now	32	2024-07-13 19:13:04.057977+00
153	41	\N	Solve actual problems.	32	2024-07-13 19:13:20.393728+00
154	\N	153	One thing to remember is real-world jobs will often have a fairly limited set of problems. Plus devs often get into the "I know how to hammer, therefore everything is a nail" problem.  It's not a bad idea to look at some general SQL exercises you find online to keep a broader set of skills.	32	2024-07-13 19:13:26.923713+00
155	\N	154	This. People argue about things like if CTEs are better than temporary tables. Get good at both, and subqueries, derived tables, and table variables. Figure out what are good uses of each tool you learn. Don't be afraid to be the weirdo who tries new things.	32	2024-07-13 19:13:31.725418+00
156	\N	153	This is the way.	32	2024-07-13 19:13:36.132133+00
157	\N	153	I'd be more specific and say to be 'excellent' at sql it'll never happen by being a data analyst writing anayltical or business logic queries like those on leetcode.  You need to be a DBA only then you have to use sql to backfill data into tables, checking data integrity etc etc then you have use sql stuff like user defined functions, table valued functions, cross apply, batch inserts, loops, recursive CTEs, dynamic SQL	32	2024-07-13 19:13:41.391986+00
158	\N	153	Yeah. It's incredibly easy to write a query that returns the data you need. It's a huge pain in the ass to validate the data and make it fit a spec.	32	2024-07-13 19:13:47.82058+00
159	41	\N	To go deep you need to understand how the database engine works. You can write code in so many different ways and get the same results but by studying the execution plans (SQL server) you can get a deeper understanding of what's happening under the hood and measure / understand the differences. I do this day in day out and I'm still learning.  Source: SQL server performance tuning DBA with 20 years experience.	32	2024-07-13 19:14:06.97247+00
160	\N	159	How do you recommend understanding the database engine, even in SQL Server?	32	2024-07-13 19:14:12.040283+00
161	\N	160	Look up Brent ozar some of his you tube videos are really good on this subject	32	2024-07-13 19:14:16.1328+00
162	\N	161	You are the best, greatly appreciated	32	2024-07-13 19:14:21.05086+00
163	\N	159	Great free book for postgres: PostgreSQL 14 Internals	32	2024-07-13 19:15:08.654298+00
164	\N	163	Thank you for this. I downloaded the PDF. What made you recommend this when I mentioned SQL Server?	32	2024-07-13 19:15:19.487148+00
165	\N	164	Well, i read you message as you are fine with any database, even if it is an SQL server :/	32	2024-07-13 19:15:23.930691+00
166	\N	165	Well, i read you message as you are fine with any database, even if it is an SQL server :/	32	2024-07-13 19:15:32.730178+00
167	\N	164	this is an example comment!	32	2024-07-13 19:15:50.762362+00
168	\N	161	💪	32	2024-07-13 19:16:10.451307+00
169	8	\N	no	32	2024-07-13 19:19:35.427424+00
170	4	\N	google it	32	2024-07-13 19:19:45.021407+00
171	27	\N	speak for yourself	32	2024-07-13 19:19:52.597467+00
172	\N	171	^^	32	2024-07-13 19:19:57.309774+00
173	27	\N	lol	32	2024-07-13 19:20:09.503674+00
174	27	\N	injection	32	2024-07-13 19:20:47.02979+00
175	27	\N	&lt;script&gt;alert("")&lt;/script&gt;	32	2024-07-13 19:32:42.071679+00
176	41	\N	ciao da user1	30	2024-07-13 19:35:06.077965+00
177	43	\N	&lt;script&gt; alert( 'Hello, world!' ); &lt;/script&gt;	30	2024-07-13 19:47:03.335316+00
178	43	\N	&lt;p&gt; ciao&lt;/p&gt;	30	2024-07-13 19:49:13.486641+00
179	43	\N	&lt;b&gt; bold &lt;/b&gt;	30	2024-07-13 19:49:21.482725+00
180	43	\N	💪	30	2024-07-13 19:51:02.618833+00
181	43	\N	nice one	31	2024-07-13 21:32:24.977766+00
182	43	\N	lol	31	2024-07-13 21:32:56.577376+00
\.


--
-- Data for Name: posts; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.posts (author, content, created_at, post_id) FROM stdin;
1	Hello World!	2023-01-01 00:00:00+00	1
7	Database optimization tips.	2023-01-07 06:00:00+00	4
9	Going for a hike today.	2023-01-09 08:00:00+00	6
10	Best practices in coding.	2023-01-10 09:00:00+00	7
12	Traveling soon, any tips?	2023-01-12 11:00:00+00	8
13	Trying out a new recipe!	2023-01-13 12:00:00+00	9
14	Why I love coding.	2023-01-14 13:00:00+00	10
15	Just started a new project.	2023-01-15 14:00:00+00	11
16	Favorite programming languages.	2023-01-16 15:00:00+00	12
17	Tips for working remotely.	2023-01-17 16:00:00+00	13
18	How to manage time effectively.	2023-01-18 17:00:00+00	14
19	Best apps for productivity.	2023-01-19 18:00:00+00	15
20	Books everyone should read.	2023-01-20 19:00:00+00	16
1	How to start a blog.	2023-01-21 20:00:00+00	17
2	Learning new technologies.	2023-01-22 21:00:00+00	18
3	The joy of open-source.	2023-01-23 22:00:00+00	19
4	Workout routines under 30 minutes.	2023-01-24 23:00:00+00	20
5	Healthy eating habits.	2023-01-25 00:00:00+00	21
6	Review of the latest tech gadgets.	2023-01-26 01:00:00+00	22
7	Early morning routines.	2023-01-27 02:00:00+00	23
8	How to stay focused.	2023-01-28 03:00:00+00	24
9	The importance of hobbies.	2023-01-29 04:00:00+00	25
10	DIY projects to try.	2023-01-30 05:00:00+00	26
29	Learning SQL is fun!	2023-01-03 02:00:00+00	27
29	Just posted my first article.	2023-01-04 03:00:00+00	28
29	JavaScript or Python?	2023-01-06 05:00:00+00	29
29	How to stay motivated.	2023-01-11 10:00:00+00	30
46	Ciao! sono user17	2024-07-13 15:42:07.863763+00	38
42	alfa brera	2024-07-13 15:45:41.316413+00	39
42	test commenti	2024-07-13 15:46:28.384491+00	40
32	So I just started learning recursive CTE and I think I’m gonna go crazy. I know it basically works like a WHILE but at the same time it doesn’t? Like, I was doing some basic stuff like calculating a number’s factorial and it went nicely, but then I tried doing a hierarchy level query and I couldn’t figure anything out. I think I understand what the anchor member is supposed to do, but what about the recursive? I know it will keep going until the termination clause is met, but what about when there’s no explicit termination member? Then will it only end when the selected anchor member reaches its last member? Can anyone give me a general explanation, because I think Im getting deranged trying to understand it	2024-07-13 19:11:37.341112+00	41
30	&lt;script&gt; alert( 'Hello, world!' ); &lt;/script&gt;	2024-07-13 19:39:55.919485+00	43
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (user_id, session_start, token) FROM stdin;
1	2024-07-01 20:43:49.665924+00	cdc88efe-68cb-4440-9710-5f76d77117de
2	2024-07-01 20:43:49.665924+00	9aaba57f-a632-4f81-959d-74d7fa99a52e
3	2024-07-01 20:43:49.665924+00	b47781f1-3892-4856-baba-2ffe929eafed
4	2024-07-01 20:43:49.665924+00	af4bb61c-bb82-4d6d-95a1-65690d26ebf4
25	2024-07-02 20:40:03.370253+00	415be71d-9011-493f-b907-e6d6ff70a05f
25	2024-07-02 20:40:21.262913+00	237bae67-3bc2-4ce3-a25d-31af4a139676
25	2024-07-02 20:40:51.351586+00	bf91e3f7-d164-45f6-935c-5fd0c020ef3e
25	2024-07-02 20:41:14.778635+00	a9e67034-4f08-4279-a375-72552b07849e
29	2024-07-03 11:59:47.155909+00	5de9400e-47b0-4e07-9ece-962c8a60e88d
29	2024-07-03 13:28:59.082332+00	a3e5deaf-7a94-4bff-984b-12e78d90dc5a
29	2024-07-03 16:27:07.948878+00	70d7d069-0b17-4512-8b2b-baed57a06eb9
25	2024-07-03 16:53:42.202309+00	13c544b2-17f0-4fe6-80e1-9203ad817fd7
29	2024-07-10 07:18:21.0952+00	e31690c7-f0a7-4c2c-8eaa-4f3bfa710160
25	2024-07-10 07:18:55.892815+00	7f49339d-de08-424d-9df5-e3b112e3dbde
29	2024-07-10 07:20:53.261289+00	02ba12c7-d6d0-4aa3-9ce4-00142e4870ae
25	2024-07-10 07:48:58.022382+00	07868c5d-8145-4e56-97ca-d5c0fab9171c
25	2024-07-12 13:42:19.958288+00	09ad8707-10d4-458f-93d1-7a46b9c806f5
29	2024-07-12 14:54:51.220368+00	c742951e-f459-48a5-8bbd-fbab869768ae
29	2024-07-12 17:19:23.890069+00	3403e815-c738-44e4-830b-f744cd1892fb
25	2024-07-12 19:22:48.746455+00	bf9473ed-1ba5-4320-8305-890eea258830
29	2024-07-13 12:41:19.374417+00	6764f108-ef0f-4b43-b82b-2af943037a83
29	2024-07-13 13:41:38.709538+00	301b7eb1-2bcb-4dce-8d9e-65068c53badb
29	2024-07-13 15:17:57.166355+00	549cf09e-a8a8-4764-a3b9-e8f1ca7a54f0
25	2024-07-13 15:23:09.847416+00	2e37a4d5-db9e-46c7-a151-f3b802a85103
46	2024-07-13 15:41:53.044964+00	d2361964-88d4-487e-b569-972b9ab529a9
42	2024-07-13 15:44:54.866387+00	90c50be9-db21-48c9-b478-a98d7c8eca82
41	2024-07-13 15:45:50.315267+00	49d9a15e-cb73-4191-a660-19a7c19ec6eb
42	2024-07-13 15:46:05.649659+00	793a5ea2-a1db-4cc4-96f9-8b9e2c82ac55
32	2024-07-13 18:58:29.516449+00	819bb677-194d-40d9-842c-c9d2eba6452c
30	2024-07-13 19:34:59.275821+00	b76f33aa-3ea4-4cb6-98f6-00a20fb3a025
31	2024-07-13 21:26:22.149353+00	73b56ae1-c25a-4a96-8af3-45a12cb4cb8d
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (user_id, username, name, surname, password, is_admin) FROM stdin;
1	jdoe	John	Doe	$2a$06$vZZcmNCdLhGRHgzo0xpnzelPjzLRALnTEPVvmkMvtrsbGYoem6Aym	f
2	asmith	Alice	Smith	$2a$06$BUkoJsXC9sySUfh0cMEs2uvGBxWELzBXEG43ykaduIrR1oeX1sT/u	f
3	bjones	Bob	Jones	$2a$06$KnuC4pIFi3Wl5uMZk.ZTmuvC7Y5PRaE.ZgjmQ3HgyIGnHzMZCEtDa	f
4	cmiller	Carol	Miller	$2a$06$tqmmdC1QabMe7CJc/AA.K.gnhEa.qEsZY2aUhykYdgjijDt2m0.0u	f
5	dlee	David	Lee	$2a$06$ORQzyv6hL6Mamx123S7W.OOldtnmCO8bKwYwq684.rRmVzO.z9Y.O	f
6	eclark	Eva	Clark	$2a$06$Cpe/nHlRwnJcKjDH8is/MeunJMTORQZJTR9CW1pjC786KtnvrqyBG	f
7	fhernandez	Frank	Hernandez	$2a$06$vUmuN5bfcLldzc2Q1n3aKef/tGqsp0V.bLNrK70t2CfJ9FUT8CxXW	f
8	gmoore	Grace	Moore	$2a$06$NHGFuOLduFwWO0Elx6ikwO0wQtdeaV1jtAensPX9TgreKRYoKUEtq	f
9	hhall	Henry	Hall	$2a$06$Ti6Z47DwjhlHp29pcw2np.Ycq5qH/Vd03.FyRqcIjYWLdcCeUtVm6	f
10	ijohnson	Ivy	Johnson	$2a$06$pyt3TS04b1sPNRBqYXHcjeEZO45BLQsK32wHROTAMsUZY6I07ugUK	f
11	jkim	Jack	Kim	$2a$06$bxDKOjh9goOVdwRfx8Q0L.A110Bgy/fK7Pj8/LrwmkXITyMrxqcuu	f
12	klopez	Karen	Lopez	$2a$06$3uH6I1l65Rt1M7Rhg/FRgOJWVSpev0PHSNVo5Ag3ExBuYw5twp3eW	f
13	lsanders	Luke	Sanders	$2a$06$HaeNH2tDGZ5hGMz9q2D55unzhTOcywtJKWXuwnueDppbPCESVBpD6	f
14	mwhite	Mona	White	$2a$06$.KBbFHDAX0kEIcnZNC8ycuV2x9gqcNmCpjRVaDyOlME9DB/VcxLKq	f
15	nmartin	Nick	Martin	$2a$06$l2pnGx4t7jC9M7/hT.27ne47rPf6ErzM28UJVrgZ0zZZ2B.ENSuPS	f
16	operez	Oscar	Perez	$2a$06$gdoVCpvqu3KgvAZU5l9eIOSDzERfWknJ.UAZblNMTL57xoAXRpW6q	f
17	pgreen	Paul	Green	$2a$06$jHjaHvWyFB8iQ61QrIkKau400UVn5mkU4aGxe/HhQIkS.9qsaTLUa	f
18	rscott	Rachel	Scott	$2a$06$dAUqQg3F6W99msdMsFHmbe/TWvBn5Tsd.4mNreu3/aahAjdfDPVoa	f
19	tallen	Tom	Allen	$2a$06$huLTBSJ1mwkdJauJ/t6VPOxhImQHb.dOmCu7./rOpoHtzQjgwNAsq	f
20	uwilson	Uma	Wilson	$2a$06$3IvZYYWWHuewqX6VSMc/jush4YeXxi4Cprt.U9.uZUYYIiyUVXEfW	f
25	admin	name	surname	$2a$06$RnwBms1B5jSV003sBCZqtOx2SaTvNyaqs2pwNdVuE9JnEGP3wxyGu	t
29	user	name	surname	$2a$06$VYFO1xwgX1GFAG5SPp9zWeGppQOQA6qY1FWGJdxXAxHSOIMmIb/sm	f
30	user1	name1	surname1	$2a$06$aK/8..Eey1xmTPRDhQ1u1er/y332tovDHYkMGxE8PcWY.X84NGEZi	f
31	user2	name2	surname2	$2a$06$mW.2vwNcmgHR30UfVLlqI.FuCdw8l8HiQbpG1SaM3kj.y3Kuij3T6	f
32	user3	name3	surname3	$2a$06$lba9Sip8NrYX9t7e4C.UzefO7Psm8RdctJ0ebvDk7xKkJ/ZPVOK9S	f
33	user4	name4	surname4	$2a$06$7LIwLItYckiMEyjcYF/Le.EvAK5bwEs3lBW68RXpu69D9zirHbtqC	f
34	user5	name5	surname5	$2a$06$QdCaYDE2RfzW1opJJowbPObfH3xdaAewwzo.NErVUjfcxLIM0a62G	f
35	user6	name6	surname6	$2a$06$RPV5qDw45vdGRoOoWOOJFeTX3cCX0aiL7CICDw.ZTKeV.//HaKTr.	f
36	user7	name7	surname7	$2a$06$ektqduVNKpmoihEdRMgRuuRuNhIv5ByuFMIamvdoNX2NWqKjvO76.	f
37	user8	name8	surname8	$2a$06$H1HtG36tg9sG8FcKek48bue5Y2wVxyP/.DrfjtEmQEr5Zbz5h1cuq	f
38	user9	name9	surname9	$2a$06$V2uDMzw7aaKxnPaGQG05AeE4h5IRsrTcs822hr.ToEWAvdR/40a9G	f
39	user10	name10	surname10	$2a$06$rTQvhwPkV9/q/ydCf.uFLe89B91rXrY3hJRUkxPZ.UUGlHB4XoINm	f
40	user11	name11	surname11	$2a$06$aFvJ9dhc9sedc8.8Qq.9s.1Zx50XKuIgyyUSA2hiLgA8EN0cNycMe	f
41	user12	name12	surname12	$2a$06$UK9g3i0skkqY4uyc5I/cK.ipGL5zVHGt1glDNcpDvD4nqrfz93NCm	f
42	user13	name13	surname13	$2a$06$sCwVYYe3gOU5zommENoFmuF7dAFWq96tJfe5Yi0d8lc6kUmtd15vy	f
43	user14	name14	surname14	$2a$06$SfpSJUOgm9OL07EjJnaZj.xTGSCQcGdj1Ldf.k8oaL6YIHErsNnim	f
44	user15	name15	surname15	$2a$06$3odbUJC9cBa.sWdiqfKHYexl46/2Eiit10j/4qa7jMKgfPJybvmd6	f
45	user16	name16	surname16	$2a$06$5jrqAcidSGLjc7.82Ov6leTNeOKTPY9nJWFR3LDMakNXRm6wjf9mi	f
46	user17	name17	surname17	$2a$06$7iAWHUiVxAboqRz8m8C3N.YSOQtDcxALHXYKqAzH5BtNFHAeZ/GpS	f
47	user18	name18	surname18	$2a$06$CrZ4nfdAO0mIanxzapy92.ejyVv9CFqrrfhnzqNpxZNiga7BnGYT.	f
48	user19	name19	surname19	$2a$06$KTpM8A/sGEQKGFNGPzGx0ugHbeCJ4DXkvnn1NGt1ivpQEXPu4aRnW	f
49	user20	name20	surname20	$2a$06$rWh3dbiPlTApzAhg1gtnw.9z2UiMS3KNFlKuiuLgurEEsvolVcAG6	f
\.


--
-- Name: comments_comment_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.comments_comment_id_seq', 182, true);


--
-- Name: posts_post_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.posts_post_id_seq', 43, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 49, true);


--
-- Name: comments comments_pk; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pk PRIMARY KEY (comment_id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (post_id);


--
-- Name: sessions session_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT session_pkey PRIMARY KEY (user_id, session_start);


--
-- Name: sessions unique_token; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT unique_token UNIQUE (token);


--
-- Name: users unique_username; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT unique_username UNIQUE (username);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: comments comments_comments_comment_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_comments_comment_id_fk FOREIGN KEY (referenced_comment_id) REFERENCES public.comments(comment_id);


--
-- Name: comments comments_posts_post_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_posts_post_id_fk FOREIGN KEY (referenced_post_id) REFERENCES public.posts(post_id);


--
-- Name: comments comments_users_user_id_fk; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_users_user_id_fk FOREIGN KEY (commenter) REFERENCES public.users(user_id);


--
-- Name: posts posts_author_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_author_fkey FOREIGN KEY (author) REFERENCES public.users(user_id);


--
-- Name: sessions session_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT session_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(user_id);


--
-- PostgreSQL database dump complete
--

