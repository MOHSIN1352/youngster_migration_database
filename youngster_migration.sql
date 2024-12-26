--
-- PostgreSQL database dump
--

-- Dumped from database version 16.3
-- Dumped by pg_dump version 16.3

-- Started on 2024-12-26 18:13:23

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
-- TOC entry 6 (class 2615 OID 17671)
-- Name: YM_DB; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA "YM_DB";


ALTER SCHEMA "YM_DB" OWNER TO postgres;

--
-- TOC entry 244 (class 1255 OID 18004)
-- Name: increment_education_employment(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.increment_education_employment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    new_education_id INT;
    new_employment_id INT;
BEGIN
    -- Insert a new education record and get its ID
    INSERT INTO Education (Institute_ID, Region_ID, Start_Date, End_Date)
    VALUES (NULL, NULL, NULL, NULL) RETURNING Education_ID INTO new_education_id;

    -- Insert a new employment record and get its ID
    INSERT INTO Employment (Industry_Type, Salary)
    VALUES (NULL, NULL) RETURNING Employment_ID INTO new_employment_id;

    -- Update the Youngster table with the new IDs
    NEW.Education_ID := new_education_id;
    NEW.Employment_ID := new_employment_id;

    RETURN NEW;
END;
$$;


ALTER FUNCTION public.increment_education_employment() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 232 (class 1259 OID 17853)
-- Name: employment; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employment (
    job_id integer NOT NULL,
    industry_type character varying(100) NOT NULL,
    salary numeric(10,2) NOT NULL,
    start_date date NOT NULL,
    end_date date,
    CONSTRAINT employment_check CHECK ((end_date > start_date)),
    CONSTRAINT employment_salary_check CHECK ((salary >= (0)::numeric)),
    CONSTRAINT employment_start_date_check CHECK ((start_date < CURRENT_DATE))
);


ALTER TABLE public.employment OWNER TO postgres;

--
-- TOC entry 230 (class 1259 OID 17842)
-- Name: youngster; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.youngster (
    youngster_id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(100) NOT NULL,
    gender character varying(10),
    education_id integer,
    employment_id integer,
    place_of_origin character varying(255),
    date_of_birth date NOT NULL,
    CONSTRAINT youngster_date_of_birth_check CHECK ((date_of_birth < CURRENT_DATE)),
    CONSTRAINT youngster_gender_check CHECK (((gender)::text = ANY ((ARRAY['Male'::character varying, 'Female'::character varying, 'Other'::character varying])::text[])))
);


ALTER TABLE public.youngster OWNER TO postgres;

--
-- TOC entry 241 (class 1259 OID 17992)
-- Name: active_employment; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.active_employment AS
 SELECT youngster.name,
    employment.industry_type,
    employment.start_date,
    employment.end_date
   FROM (public.youngster
     JOIN public.employment ON ((youngster.employment_id = employment.job_id)))
  WHERE ((employment.end_date IS NULL) OR (employment.end_date > CURRENT_DATE));


ALTER VIEW public.active_employment OWNER TO postgres;

--
-- TOC entry 236 (class 1259 OID 17892)
-- Name: migration_event; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migration_event (
    migration_id integer NOT NULL,
    youngster_id integer NOT NULL,
    duration integer NOT NULL,
    from_region integer NOT NULL,
    to_region integer NOT NULL,
    migration_date date NOT NULL,
    CONSTRAINT migration_event_duration_check CHECK ((duration >= 0)),
    CONSTRAINT migration_event_migration_date_check CHECK ((migration_date < CURRENT_DATE))
);


ALTER TABLE public.migration_event OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 17996)
-- Name: avg_migration_duration; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.avg_migration_duration AS
 SELECT from_region,
    to_region,
    avg(duration) AS avg_duration
   FROM public.migration_event
  GROUP BY from_region, to_region;


ALTER VIEW public.avg_migration_duration OWNER TO postgres;

--
-- TOC entry 219 (class 1259 OID 17764)
-- Name: city; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.city (
    city_id integer NOT NULL,
    city_name character varying(100) NOT NULL,
    state_id integer NOT NULL
);


ALTER TABLE public.city OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 18000)
-- Name: avgmigration_duration; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.avgmigration_duration AS
 SELECT fromcity.city_name AS from_city,
    tocity.city_name AS to_city,
    avg(migration_event.duration) AS avg_duration
   FROM ((public.migration_event
     JOIN public.city fromcity ON ((migration_event.from_region = fromcity.city_id)))
     JOIN public.city tocity ON ((migration_event.to_region = tocity.city_id)))
  GROUP BY fromcity.city_name, tocity.city_name;


ALTER VIEW public.avgmigration_duration OWNER TO postgres;

--
-- TOC entry 218 (class 1259 OID 17763)
-- Name: city_city_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.city_city_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.city_city_id_seq OWNER TO postgres;

--
-- TOC entry 5013 (class 0 OID 0)
-- Dependencies: 218
-- Name: city_city_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.city_city_id_seq OWNED BY public.city.city_id;


--
-- TOC entry 226 (class 1259 OID 17803)
-- Name: climate; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.climate (
    city_id integer NOT NULL,
    policy_id integer NOT NULL,
    average_temp numeric(5,2) NOT NULL,
    climate_type character varying(50) NOT NULL,
    CONSTRAINT climate_average_temp_check CHECK (((average_temp >= ('-50'::integer)::numeric) AND (average_temp <= (60)::numeric)))
);


ALTER TABLE public.climate OWNER TO postgres;

--
-- TOC entry 234 (class 1259 OID 17868)
-- Name: education; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.education (
    education_id integer NOT NULL,
    institute_id integer NOT NULL,
    city_id integer NOT NULL,
    start_date date NOT NULL,
    end_date date,
    CONSTRAINT education_check CHECK ((end_date > start_date)),
    CONSTRAINT education_start_date_check CHECK ((start_date < CURRENT_DATE))
);


ALTER TABLE public.education OWNER TO postgres;

--
-- TOC entry 233 (class 1259 OID 17867)
-- Name: education_education_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.education_education_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.education_education_id_seq OWNER TO postgres;

--
-- TOC entry 5014 (class 0 OID 0)
-- Dependencies: 233
-- Name: education_education_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.education_education_id_seq OWNED BY public.education.education_id;


--
-- TOC entry 223 (class 1259 OID 17787)
-- Name: employer; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.employer (
    employer_id integer NOT NULL,
    employer_name character varying(100) NOT NULL,
    location character varying(100),
    salary_benefits integer
);


ALTER TABLE public.employer OWNER TO postgres;

--
-- TOC entry 222 (class 1259 OID 17786)
-- Name: employer_employer_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employer_employer_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employer_employer_id_seq OWNER TO postgres;

--
-- TOC entry 5015 (class 0 OID 0)
-- Dependencies: 222
-- Name: employer_employer_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employer_employer_id_seq OWNED BY public.employer.employer_id;


--
-- TOC entry 231 (class 1259 OID 17852)
-- Name: employment_job_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.employment_job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.employment_job_id_seq OWNER TO postgres;

--
-- TOC entry 5016 (class 0 OID 0)
-- Dependencies: 231
-- Name: employment_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.employment_job_id_seq OWNED BY public.employment.job_id;


--
-- TOC entry 239 (class 1259 OID 17919)
-- Name: enrolled; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.enrolled (
    youngster_id integer NOT NULL,
    institute_id integer NOT NULL,
    enrollment_date date NOT NULL,
    completion_status boolean NOT NULL,
    credits integer NOT NULL,
    grade character varying(10),
    CONSTRAINT enrolled_credits_check CHECK ((credits >= 0)),
    CONSTRAINT enrolled_enrollment_date_check CHECK ((enrollment_date < CURRENT_DATE))
);


ALTER TABLE public.enrolled OWNER TO postgres;

--
-- TOC entry 228 (class 1259 OID 17815)
-- Name: government_policy; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.government_policy (
    policy_id integer NOT NULL,
    policy_name character varying(255) NOT NULL,
    policy_type character varying(100) NOT NULL,
    state_id integer
);


ALTER TABLE public.government_policy OWNER TO postgres;

--
-- TOC entry 227 (class 1259 OID 17814)
-- Name: government_policy_policy_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.government_policy_policy_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.government_policy_policy_id_seq OWNER TO postgres;

--
-- TOC entry 5017 (class 0 OID 0)
-- Dependencies: 227
-- Name: government_policy_policy_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.government_policy_policy_id_seq OWNED BY public.government_policy.policy_id;


--
-- TOC entry 225 (class 1259 OID 17796)
-- Name: health_facility; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.health_facility (
    facility_id integer NOT NULL,
    name character varying(255) NOT NULL,
    facility_type character varying(100) NOT NULL,
    bed_capacity integer NOT NULL,
    CONSTRAINT health_facility_bed_capacity_check CHECK ((bed_capacity >= 0))
);


ALTER TABLE public.health_facility OWNER TO postgres;

--
-- TOC entry 224 (class 1259 OID 17795)
-- Name: health_facility_facility_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.health_facility_facility_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.health_facility_facility_id_seq OWNER TO postgres;

--
-- TOC entry 5018 (class 0 OID 0)
-- Dependencies: 224
-- Name: health_facility_facility_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.health_facility_facility_id_seq OWNED BY public.health_facility.facility_id;


--
-- TOC entry 221 (class 1259 OID 17776)
-- Name: institute; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.institute (
    institution_id integer NOT NULL,
    name character varying(255) NOT NULL,
    tuition_fees numeric(10,2) NOT NULL,
    address text NOT NULL,
    website character varying(255),
    accreditation_status boolean NOT NULL,
    established_year integer,
    type character varying(50) NOT NULL,
    CONSTRAINT institute_established_year_check CHECK ((established_year > 0)),
    CONSTRAINT institute_tuition_fees_check CHECK ((tuition_fees >= (0)::numeric))
);


ALTER TABLE public.institute OWNER TO postgres;

--
-- TOC entry 220 (class 1259 OID 17775)
-- Name: institute_institution_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.institute_institution_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.institute_institution_id_seq OWNER TO postgres;

--
-- TOC entry 5019 (class 0 OID 0)
-- Dependencies: 220
-- Name: institute_institution_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.institute_institution_id_seq OWNED BY public.institute.institution_id;


--
-- TOC entry 235 (class 1259 OID 17891)
-- Name: migration_event_migration_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migration_event_migration_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migration_event_migration_id_seq OWNER TO postgres;

--
-- TOC entry 5020 (class 0 OID 0)
-- Dependencies: 235
-- Name: migration_event_migration_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migration_event_migration_id_seq OWNED BY public.migration_event.migration_id;


--
-- TOC entry 238 (class 1259 OID 17906)
-- Name: opportunities; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.opportunities (
    opportunity_id integer NOT NULL,
    opportunity_type character varying(100) NOT NULL,
    location character varying(255) NOT NULL,
    employer_id integer NOT NULL,
    salary_benefits text NOT NULL,
    eligibility_criteria text NOT NULL
);


ALTER TABLE public.opportunities OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 17905)
-- Name: opportunities_opportunity_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.opportunities_opportunity_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.opportunities_opportunity_id_seq OWNER TO postgres;

--
-- TOC entry 5021 (class 0 OID 0)
-- Dependencies: 237
-- Name: opportunities_opportunity_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.opportunities_opportunity_id_seq OWNED BY public.opportunities.opportunity_id;


--
-- TOC entry 217 (class 1259 OID 17753)
-- Name: state; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.state (
    state_id integer NOT NULL,
    state_name character varying(100) NOT NULL
);


ALTER TABLE public.state OWNER TO postgres;

--
-- TOC entry 216 (class 1259 OID 17752)
-- Name: state_state_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.state_state_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.state_state_id_seq OWNER TO postgres;

--
-- TOC entry 5022 (class 0 OID 0)
-- Dependencies: 216
-- Name: state_state_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.state_state_id_seq OWNED BY public.state.state_id;


--
-- TOC entry 240 (class 1259 OID 17981)
-- Name: youngster_phone; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.youngster_phone (
    youngster_id integer NOT NULL,
    phone_no character varying(15) NOT NULL
);


ALTER TABLE public.youngster_phone OWNER TO postgres;

--
-- TOC entry 229 (class 1259 OID 17841)
-- Name: youngster_youngster_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.youngster_youngster_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.youngster_youngster_id_seq OWNER TO postgres;

--
-- TOC entry 5023 (class 0 OID 0)
-- Dependencies: 229
-- Name: youngster_youngster_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.youngster_youngster_id_seq OWNED BY public.youngster.youngster_id;


--
-- TOC entry 4765 (class 2604 OID 17767)
-- Name: city city_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city ALTER COLUMN city_id SET DEFAULT nextval('public.city_city_id_seq'::regclass);


--
-- TOC entry 4772 (class 2604 OID 17871)
-- Name: education education_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.education ALTER COLUMN education_id SET DEFAULT nextval('public.education_education_id_seq'::regclass);


--
-- TOC entry 4767 (class 2604 OID 17790)
-- Name: employer employer_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer ALTER COLUMN employer_id SET DEFAULT nextval('public.employer_employer_id_seq'::regclass);


--
-- TOC entry 4771 (class 2604 OID 17856)
-- Name: employment job_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employment ALTER COLUMN job_id SET DEFAULT nextval('public.employment_job_id_seq'::regclass);


--
-- TOC entry 4769 (class 2604 OID 17818)
-- Name: government_policy policy_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.government_policy ALTER COLUMN policy_id SET DEFAULT nextval('public.government_policy_policy_id_seq'::regclass);


--
-- TOC entry 4768 (class 2604 OID 17799)
-- Name: health_facility facility_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_facility ALTER COLUMN facility_id SET DEFAULT nextval('public.health_facility_facility_id_seq'::regclass);


--
-- TOC entry 4766 (class 2604 OID 18008)
-- Name: institute institution_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.institute ALTER COLUMN institution_id SET DEFAULT nextval('public.institute_institution_id_seq'::regclass);


--
-- TOC entry 4773 (class 2604 OID 17895)
-- Name: migration_event migration_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_event ALTER COLUMN migration_id SET DEFAULT nextval('public.migration_event_migration_id_seq'::regclass);


--
-- TOC entry 4774 (class 2604 OID 17909)
-- Name: opportunities opportunity_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunities ALTER COLUMN opportunity_id SET DEFAULT nextval('public.opportunities_opportunity_id_seq'::regclass);


--
-- TOC entry 4764 (class 2604 OID 17756)
-- Name: state state_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.state ALTER COLUMN state_id SET DEFAULT nextval('public.state_state_id_seq'::regclass);


--
-- TOC entry 4770 (class 2604 OID 17845)
-- Name: youngster youngster_id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster ALTER COLUMN youngster_id SET DEFAULT nextval('public.youngster_youngster_id_seq'::regclass);


--
-- TOC entry 4986 (class 0 OID 17764)
-- Dependencies: 219
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.city (city_id, city_name, state_id) FROM stdin;
1	Visakhapatnam	1
2	Vijayawada	1
3	Itanagar	2
4	Guwahati	3
5	Patna	4
6	Raipur	5
7	Panaji	6
8	Ahmedabad	7
9	Gurugram	8
10	Shimla	9
11	Ranchi	10
12	Bengaluru	11
13	Thiruvananthapuram	12
14	Bhopal	13
15	Mumbai	14
16	Imphal	15
17	Shillong	16
18	Aizawl	17
19	Kohima	18
20	Bhubaneswar	19
21	Chandigarh	20
22	Jaipur	21
23	Gangtok	22
24	Chennai	23
25	Hyderabad	24
26	Agartala	25
27	Lucknow	26
28	Dehradun	27
29	Kolkata	28
30	Port Blair	29
32	Diu	31
33	Kavaratti	32
34	Delhi	33
35	Puducherry	34
36	Srinagar	35
37	Leh	36
38	Jodhpur	21
39	Ahmednagar	14
40	Nashik	14
41	Nagpur	14
43	Warangal	24
44	Gwalior	13
45	Kota	21
46	Bikaner	21
47	Jaisalmer	21
48	Mysuru	11
49	Belgaum	11
50	Kochi	12
51	Thrissur	12
53	Dimapur	18
54	Dibrugarh	3
55	Bhatinda	20
56	Ludhiana	20
57	Vapi	7
58	Vadodara	7
59	Navi Mumbai	14
60	Kalyan	14
61	Cuttack	19
62	Mangalore	11
63	Rourkela	19
64	Jamshedpur	10
65	Dhanbad	10
68	Siliguri	28
69	Agra	26
70	Varanasi	26
71	Noida	33
72	Ghaziabad	26
73	Faridabad	8
75	Sagar	13
76	Khandwa	13
77	Sangli	14
78	Kolhapur	14
79	Aurangabad	14
80	Nanded	14
81	Jalna	14
82	Kalyan-Dombivli	14
83	Dharamshala	9
84	Solan	9
85	Palakkad	12
86	Kottayam	12
87	Tirupati	1
88	Nellore	1
89	Eluru	1
90	Rangpo	22
91	Dharamkot	9
92	Bhuj	7
93	Porbandar	7
94	Udaipur	21
95	Ajmer	21
96	Durgapur	28
97	Bardhaman	28
98	Jabalpur	13
99	Indore	13
100	Madhubani	4
101	Darbhanga	4
102	Gandhinagar	7
103	Kharagpur	28
104	Bangalore	11
105	Tiruchirappalli	23
106	Surathkal	11
107	Vellore	23
108	Manipal	11
109	Phagwara	20
110	Thanjavur	23
111	Mesra	10
113	Sri City	1
115	Neemrana	21
116	Pune	14
117	Gharuan	20
123	Coimbatore	23
125	Mandi	9
126	Bhilai	5
127	Kanpur	26
128	Pilani	21
129	Jammu	35
130	Kozhikode	12
131	Wardha	14
133	Vallabh Vidyanagar	7
135	Midnapore	28
136	Rajkot	7
137	Faridkot	20
138	Salem	23
140	Kakinada	1
141	Vasad	7
31	Araku Valley	1
42	Dharmanagar	25
52	Mirzapur	26
67	Kullu	9
74	Baramulla	35
66	Pithoragarh	27
112	Mirzapur	26
114	Bhiwadi	21
118	Ratnagiri	14
119	Rishikesh	27
120	Sonipat	8
121	Jhansi	26
122	Tonk	21
124	Palghar	14
132	Amravati	14
134	Udhampur	35
139	Hassan	11
142	Surat	7
143	Thane	14
144	Bhavnagar	7
145	Gurgaon	8
146	Meerut	26
\.


--
-- TOC entry 4993 (class 0 OID 17803)
-- Dependencies: 226
-- Data for Name: climate; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.climate (city_id, policy_id, average_temp, climate_type) FROM stdin;
1	1	25.00	Tropical
1	2	26.50	Tropical
1	3	24.00	Tropical
2	4	30.00	Tropical
2	5	31.00	Tropical
2	6	28.50	Tropical
3	7	14.00	Temperate
3	8	15.00	Temperate
3	9	13.50	Temperate
4	10	20.00	Temperate
4	11	21.00	Temperate
4	12	19.50	Temperate
5	13	8.00	Cold
5	14	9.00	Cold
5	15	7.50	Cold
6	16	27.00	Tropical
6	17	26.50	Tropical
6	18	28.50	Tropical
7	19	15.00	Mediterranean
7	20	16.50	Mediterranean
7	21	14.50	Mediterranean
8	22	12.00	Cold
8	23	11.00	Cold
8	24	10.50	Cold
9	25	22.00	Tropical
9	26	21.50	Tropical
9	27	23.00	Tropical
10	28	18.00	Temperate
10	29	19.00	Temperate
10	30	17.50	Temperate
11	31	29.00	Tropical
11	32	28.00	Tropical
11	33	30.00	Tropical
12	34	9.50	Cold
12	35	8.50	Cold
12	36	10.00	Cold
13	37	14.00	Temperate
13	38	15.50	Temperate
13	39	13.00	Temperate
14	40	31.00	Tropical
14	41	32.00	Tropical
14	42	30.50	Tropical
15	43	11.00	Cold
15	44	12.50	Cold
15	45	10.00	Cold
16	46	26.00	Tropical
16	47	25.00	Tropical
16	48	27.50	Tropical
17	49	8.00	Cold
17	50	9.50	Cold
17	51	7.50	Cold
18	52	19.00	Temperate
18	53	18.50	Temperate
18	54	20.00	Temperate
19	55	32.00	Tropical
19	56	31.50	Tropical
19	57	30.00	Tropical
20	58	14.50	Mediterranean
20	59	15.00	Mediterranean
20	60	13.50	Mediterranean
21	61	12.00	Cold
21	62	10.00	Cold
21	63	11.00	Cold
22	64	28.00	Tropical
22	65	29.50	Tropical
22	66	27.00	Tropical
23	67	17.00	Temperate
23	68	16.50	Temperate
23	69	18.50	Temperate
24	70	31.00	Tropical
24	71	32.50	Tropical
24	72	30.50	Tropical
25	73	8.00	Cold
25	74	9.00	Cold
25	75	7.00	Cold
26	76	15.00	Mediterranean
26	77	14.00	Mediterranean
26	78	16.00	Mediterranean
27	79	22.00	Tropical
27	80	21.00	Tropical
27	81	23.00	Tropical
28	82	13.50	Temperate
28	83	14.00	Temperate
28	84	12.00	Temperate
29	85	30.00	Tropical
29	86	29.00	Tropical
29	87	31.00	Tropical
30	88	9.00	Cold
30	89	8.50	Cold
30	90	10.00	Cold
32	94	26.00	Tropical
32	95	25.50	Tropical
32	96	27.50	Tropical
33	97	12.00	Mediterranean
33	98	11.00	Mediterranean
33	99	13.00	Mediterranean
34	100	30.00	Tropical
\.


--
-- TOC entry 5001 (class 0 OID 17868)
-- Dependencies: 234
-- Data for Name: education; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.education (education_id, institute_id, city_id, start_date, end_date) FROM stdin;
1	1	15	2019-08-01	2022-05-31
2	2	34	2020-01-15	\N
3	3	24	2015-06-20	2020-05-31
4	4	127	2021-08-01	2023-06-30
5	5	103	2020-09-01	2023-12-31
6	6	8	2021-05-15	\N
7	7	104	2018-07-20	2022-06-30
8	8	29	2019-03-10	2022-03-10
9	9	128	2021-08-01	\N
10	10	105	2017-11-15	2020-11-15
11	11	106	2020-02-20	2022-12-20
12	12	107	2019-04-01	\N
13	13	24	2016-09-01	2019-09-01
14	14	108	2018-01-01	2021-01-01
15	15	109	2021-02-01	\N
16	16	71	2020-08-15	\N
17	17	34	2015-05-01	2020-05-01
18	18	34	2020-08-01	2022-08-01
19	19	34	2019-09-10	2021-06-30
20	20	21	2021-10-15	\N
21	21	15	2020-03-20	2023-03-20
22	22	29	2015-02-01	2018-06-30
23	23	34	2019-11-11	\N
24	24	8	2021-01-01	2023-12-01
25	25	71	2018-05-20	2021-12-31
26	26	70	2017-12-01	\N
27	27	15	2019-04-15	2022-04-15
28	28	24	2016-08-01	\N
29	29	110	2021-03-01	2024-02-29
30	30	2	2018-07-01	\N
31	31	8	2015-04-10	2019-04-10
32	32	111	2020-09-01	\N
33	33	104	2017-11-01	2020-11-01
34	34	113	2019-10-01	2022-10-01
35	35	78	2020-06-20	\N
36	36	109	2019-01-15	2023-05-15
37	37	29	2021-12-01	\N
38	38	34	2015-03-20	2019-03-20
39	39	115	2020-05-01	2023-04-30
40	40	102	2018-10-01	2021-10-01
41	41	28	2020-04-15	\N
42	42	116	2016-07-01	2019-07-01
43	43	34	2021-08-15	\N
44	44	34	2019-12-01	2022-12-01
45	45	86	2017-02-10	\N
46	46	117	2020-03-15	2023-09-15
47	47	104	2018-05-01	\N
48	48	107	2016-06-20	2019-05-20
49	49	104	2020-07-15	\N
50	50	24	2015-09-01	2019-09-01
51	51	110	2018-01-01	\N
52	52	116	2019-02-20	2022-02-20
53	53	123	2021-11-11	\N
54	54	23	2016-03-01	\N
55	55	29	2020-01-10	2023-01-10
56	56	25	2017-08-01	\N
57	57	22	2015-12-01	2018-12-01
58	58	34	2019-09-20	\N
59	59	104	2020-05-15	\N
60	60	8	2015-10-01	2019-10-01
61	61	34	2021-02-01	\N
62	62	34	2018-03-10	\N
63	63	34	2019-01-01	2022-01-01
64	64	125	2017-11-20	\N
65	65	126	2020-04-01	2023-08-01
66	66	129	2019-07-10	\N
67	67	65	2021-05-01	2023-05-01
68	68	11	2016-09-01	\N
69	69	27	2015-06-30	2019-06-30
70	70	130	2018-12-20	\N
71	71	25	2017-02-01	\N
72	72	48	2019-01-15	\N
73	73	131	2020-03-30	\N
74	74	8	2015-08-10	\N
75	75	15	2021-04-20	2023-03-20
76	76	11	2019-05-15	\N
77	77	129	2020-07-01	\N
78	78	133	2016-10-01	2019-10-01
79	79	78	2021-08-01	\N
80	80	15	2019-06-15	\N
81	81	34	2015-03-01	2018-03-01
82	82	13	2020-11-10	\N
83	83	123	2016-07-01	\N
84	84	135	2017-02-20	2020-02-20
85	85	50	2021-09-01	\N
86	86	43	2019-08-20	\N
87	87	27	2016-04-10	2020-04-10
88	88	136	2020-01-01	\N
89	89	1	2018-12-31	2022-12-31
90	90	20	2019-05-15	\N
91	91	137	2021-07-20	\N
92	92	4	2016-03-01	2019-03-01
93	93	138	2018-11-10	\N
94	94	123	2019-09-15	\N
95	95	140	2020-01-01	\N
96	96	56	2015-06-01	\N
97	97	21	2021-03-10	\N
98	98	141	2016-08-01	\N
99	99	25	2019-10-20	\N
100	100	14	2017-12-01	\N
\.


--
-- TOC entry 4990 (class 0 OID 17787)
-- Dependencies: 223
-- Data for Name: employer; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employer (employer_id, employer_name, location, salary_benefits) FROM stdin;
1	Tata Consultancy Services	Mumbai	800000
2	Infosys	Bengaluru	750000
3	Wipro	Bengaluru	700000
4	HCL Technologies	Noida	720000
5	Accenture	Gurgaon	900000
6	Cognizant	Chennai	680000
7	Tech Mahindra	Pune	640000
8	Capgemini	Mumbai	750000
9	IBM	Bengaluru	850000
10	Oracle	Hyderabad	900000
11	SAP	Gurgaon	950000
12	Dell	Bengaluru	780000
13	Intel	Hyderabad	830000
14	Microsoft	Hyderabad	1000000
15	Amazon	Bengaluru	1200000
16	Google	Hyderabad	1100000
17	Facebook	Hyderabad	1150000
18	Adobe	Noida	900000
19	Salesforce	Bengaluru	950000
20	Cisco	Bengaluru	880000
21	Uber	Bengaluru	1000000
22	Ola	Bengaluru	700000
23	Zomato	Gurgaon	600000
24	Swiggy	Bengaluru	650000
25	Paytm	Noida	750000
26	Razorpay	Bengaluru	700000
27	PhonePe	Bengaluru	720000
28	Myntra	Bengaluru	680000
29	Nykaa	Mumbai	600000
30	Flipkart	Bengaluru	950000
31	Snapdeal	Gurgaon	500000
32	Tata Steel	Jamshedpur	700000
33	Reliance Industries	Mumbai	850000
34	Hindustan Unilever	Mumbai	900000
35	ITC	Kolkata	850000
36	L&T	Mumbai	800000
37	Godrej	Mumbai	750000
38	Mahindra & Mahindra	Mumbai	800000
39	Bajaj Auto	Pune	750000
40	TVS Motor Company	Chennai	680000
41	Hero MotoCorp	Gurgaon	700000
42	Bharat Forge	Pune	720000
43	Asian Paints	Mumbai	740000
44	Maruti Suzuki	Gurgaon	850000
45	Tata Motors	Pune	800000
46	Nirma	Ahmedabad	680000
47	P&G	Mumbai	900000
48	Nestle	Mumbai	850000
49	Coca-Cola	Bengaluru	780000
50	PepsiCo	Hyderabad	800000
51	Britannia	Mumbai	700000
52	Hindustan Aeronautics	Bengaluru	950000
53	ISRO	Bengaluru	1000000
54	DRDO	Bengaluru	900000
55	BHEL	Bhopal	800000
56	NTPC	New Delhi	850000
57	ONGC	Dehradun	900000
58	GAIL	New Delhi	750000
59	Cairn India	Rajasthan	700000
60	Adani Group	Ahmedabad	850000
61	JSW Steel	Bengaluru	800000
62	Steel Authority of India	New Delhi	720000
63	Indian Oil Corporation	New Delhi	750000
64	Hindustan Zinc	Udaipur	680000
65	Marico	Mumbai	700000
66	ITC Hotels	Kolkata	750000
67	KFC	New Delhi	600000
68	McDonald’s	Mumbai	650000
69	Domino’s Pizza	Bengaluru	620000
70	Starbucks	Mumbai	650000
71	Taj Hotels	Mumbai	800000
72	Oyo Rooms	Gurgaon	700000
73	Zomato Gold	Bengaluru	600000
74	MakeMyTrip	Gurgaon	650000
75	Cleartrip	Mumbai	580000
76	GoAir	Mumbai	620000
77	IndiGo	Gurgaon	680000
78	Air India	Mumbai	750000
79	SpiceJet	Delhi	600000
80	Vistara	Delhi	700000
81	Bharti Airtel	New Delhi	800000
82	Reliance Jio	Mumbai	850000
83	Vodafone	Mumbai	700000
84	BSNL	Mumbai	600000
85	MTNL	Mumbai	500000
86	Google Pay	Hyderabad	720000
87	PhonePe	Bengaluru	700000
88	FreeCharge	Gurgaon	650000
89	PayPal	Hyderabad	800000
90	PayU	Gurgaon	700000
91	Razorpay	Bengaluru	720000
92	Cure.fit	Bengaluru	650000
93	PharmEasy	Mumbai	700000
94	1mg	Bengaluru	680000
95	Netmeds	Hyderabad	640000
96	Zomato	Gurgaon	600000
97	Mongonese	Gandhinagar	300000
98	Lions	Ahmedabad	300000
\.


--
-- TOC entry 4999 (class 0 OID 17853)
-- Dependencies: 232
-- Data for Name: employment; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.employment (job_id, industry_type, salary, start_date, end_date) FROM stdin;
1	Information Technology	60000.00	2022-01-01	2025-01-01
2	Healthcare	50000.00	2021-02-01	2024-12-01
3	Finance	70000.00	2023-03-01	2025-03-01
4	Education	45000.00	2022-04-01	\N
5	Construction	55000.00	2020-05-01	2023-06-01
6	Manufacturing	50000.00	2019-06-01	\N
7	Retail	40000.00	2023-07-01	2025-07-01
8	Hospitality	35000.00	2020-08-01	2023-08-01
9	Transportation	45000.00	2022-09-01	\N
10	Telecommunications	65000.00	2021-10-01	2024-10-01
11	Real Estate	70000.00	2022-11-01	2025-11-01
12	Legal	75000.00	2020-12-01	\N
13	Marketing	50000.00	2023-01-01	2024-12-01
14	Media	40000.00	2021-02-01	\N
15	Agriculture	30000.00	2020-03-01	2023-03-01
16	Information Security	90000.00	2023-04-01	2025-04-01
17	Pharmaceuticals	80000.00	2021-05-01	\N
18	Aerospace	75000.00	2022-06-01	2024-06-01
19	Biotechnology	85000.00	2023-07-01	2025-07-01
20	Consulting	65000.00	2022-08-01	\N
21	Entertainment	55000.00	2023-09-01	\N
22	Insurance	60000.00	2021-10-01	2024-10-01
23	Textiles	40000.00	2022-11-01	\N
24	Food Service	35000.00	2021-12-01	2023-12-01
25	Construction Management	60000.00	2023-01-01	2025-01-01
26	Civil Engineering	70000.00	2022-02-01	2024-02-01
27	Environmental Science	50000.00	2023-03-01	2024-03-01
28	Data Analysis	80000.00	2023-04-01	\N
29	Web Development	60000.00	2022-05-01	2024-05-01
30	Graphic Design	40000.00	2023-06-01	\N
31	User Experience Design	70000.00	2021-07-01	2024-07-01
32	Content Creation	30000.00	2022-08-01	\N
33	Event Planning	35000.00	2020-09-01	\N
34	Sales	45000.00	2021-10-01	2024-10-01
35	Human Resources	50000.00	2023-01-01	\N
36	Supply Chain Management	60000.00	2021-02-01	\N
37	Public Relations	55000.00	2022-03-01	2024-03-01
38	Nonprofit Management	40000.00	2020-04-01	\N
39	Retail Management	45000.00	2022-05-01	\N
40	Property Management	50000.00	2023-06-01	2024-06-01
41	Event Management	35000.00	2022-07-01	\N
42	Business Development	60000.00	2021-08-01	2024-08-01
43	Research and Development	70000.00	2020-09-01	\N
44	Project Management	65000.00	2023-10-01	2025-10-01
45	Software Development	80000.00	2022-11-01	\N
46	Data Science	85000.00	2023-12-01	\N
47	Cybersecurity	90000.00	2023-01-01	2025-01-01
48	Cloud Computing	70000.00	2021-02-01	\N
49	Artificial Intelligence	95000.00	2022-03-01	2024-03-01
50	Machine Learning	80000.00	2023-04-01	\N
51	Blockchain	85000.00	2020-05-01	2024-05-01
52	Robotics	90000.00	2021-06-01	\N
53	Internet of Things	95000.00	2023-07-01	2025-07-01
54	Augmented Reality	70000.00	2021-08-01	\N
55	Virtual Reality	60000.00	2020-09-01	2023-09-01
56	Big Data	80000.00	2023-10-01	\N
57	Digital Marketing	70000.00	2021-11-01	2024-11-01
58	E-commerce	75000.00	2022-12-01	\N
59	SEO	65000.00	2023-01-01	\N
60	Content Marketing	60000.00	2020-02-01	2023-02-01
61	Social Media Management	55000.00	2021-03-01	\N
62	App Development	70000.00	2022-04-01	2024-04-01
63	Quality Assurance	65000.00	2023-05-01	\N
64	DevOps	80000.00	2020-06-01	\N
65	Game Development	75000.00	2021-07-01	2024-07-01
66	Product Management	90000.00	2023-08-01	2025-08-01
67	Technical Support	50000.00	2022-09-01	\N
68	Sales Management	65000.00	2021-10-01	\N
69	Business Analysis	70000.00	2020-11-01	2023-11-01
70	Financial Analysis	80000.00	2023-12-01	\N
71	Operations Management	70000.00	2021-01-01	\N
72	Strategic Planning	75000.00	2022-02-01	\N
73	Customer Service	60000.00	2020-03-01	\N
74	Market Research	55000.00	2021-04-01	\N
75	Policy Analysis	70000.00	2023-05-01	\N
76	Community Development	40000.00	2021-06-01	\N
77	Mental Health	50000.00	2020-07-01	2023-07-01
78	Consultative Selling	60000.00	2022-08-01	2024-08-01
79	Account Management	55000.00	2021-09-01	\N
80	Risk Management	70000.00	2023-10-01	\N
81	Facilities Management	50000.00	2021-11-01	\N
82	Logistics	60000.00	2023-12-01	\N
83	Energy Management	75000.00	2023-01-01	\N
84	Health and Safety	60000.00	2022-02-01	2025-02-01
85	Environmental Engineering	80000.00	2021-03-01	\N
86	Sustainability Consulting	70000.00	2023-04-01	2024-04-01
87	Telecommunications Engineering	85000.00	2020-05-01	\N
88	Cybersecurity Analysis	95000.00	2022-06-01	2025-06-01
89	Data Governance	75000.00	2021-07-01	\N
90	Artificial Intelligence Research	95000.00	2023-08-01	\N
91	User Interface Design	70000.00	2022-09-01	2024-09-01
92	Network Administration	60000.00	2021-10-01	\N
93	Health Informatics	70000.00	2023-11-01	\N
94	Pharmaceutical Sales	75000.00	2020-12-01	2023-12-01
95	Regulatory Affairs	80000.00	2022-01-01	\N
96	Nonprofit Fundraising	40000.00	2023-02-01	2025-02-01
97	Training and Development	60000.00	2021-03-01	\N
98	Corporate Social Responsibility	65000.00	2022-04-01	\N
99	International Relations	70000.00	2023-05-01	\N
100	Business Intelligence	80000.00	2022-06-01	\N
121	Unemployed	1.00	2000-01-01	2001-01-01
\.


--
-- TOC entry 5006 (class 0 OID 17919)
-- Dependencies: 239
-- Data for Name: enrolled; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.enrolled (youngster_id, institute_id, enrollment_date, completion_status, credits, grade) FROM stdin;
1	36	2020-08-15	t	30	A
2	8	2019-09-10	f	28	B
3	43	2021-01-12	t	34	A
4	10	2022-07-20	t	40	A
5	19	2018-05-25	f	20	C
6	64	2020-11-30	t	32	B
7	52	2021-02-14	t	36	A
8	27	2022-06-18	f	22	C
9	49	2019-10-11	t	30	B
10	15	2023-01-01	t	28	A
11	60	2020-03-30	f	25	B
12	30	2021-04-12	t	35	A
13	78	2019-08-21	t	31	A
14	42	2022-02-16	f	27	C
15	54	2020-12-01	t	29	B
16	70	2021-03-05	t	38	A
17	33	2018-06-29	f	21	C
18	5	2019-11-14	t	36	B
19	66	2021-08-20	t	34	A
20	88	2020-04-25	t	37	A
21	81	2019-10-30	f	29	B
22	94	2022-07-09	t	40	A
23	37	2018-05-18	t	31	B
24	91	2020-11-22	f	30	C
25	47	2021-02-28	t	35	A
26	73	2019-09-15	t	33	B
27	50	2021-01-01	f	26	C
28	14	2020-05-05	t	30	A
29	63	2019-08-16	t	32	B
30	12	2021-03-18	f	27	C
31	59	2019-02-22	t	35	A
32	84	2021-06-17	t	38	A
33	39	2020-07-07	f	24	B
34	11	2019-03-13	t	28	A
35	92	2021-01-30	t	36	B
36	76	2020-08-02	t	40	A
37	68	2019-10-15	f	22	C
38	45	2021-05-05	t	29	A
39	86	2020-04-12	t	31	B
40	80	2019-09-21	t	35	A
41	26	2021-03-02	f	24	C
42	99	2020-12-29	t	36	B
43	1	2022-11-05	t	40	A
44	74	2019-07-04	f	21	C
45	24	2021-08-17	t	33	A
46	67	2020-09-28	t	30	B
47	95	2019-05-15	f	27	C
48	62	2021-02-20	t	38	A
49	18	2020-03-06	t	34	B
50	53	2021-07-01	t	30	A
51	34	2019-04-14	t	29	B
52	35	2022-05-10	f	20	C
53	8	2019-11-21	t	37	A
54	90	2020-06-15	t	32	B
55	56	2021-01-05	t	40	A
56	82	2022-04-11	f	24	C
57	13	2020-08-13	t	30	A
58	44	2021-03-03	t	33	B
59	72	2019-06-19	t	35	A
60	9	2022-07-08	f	22	C
61	48	2020-12-12	t	29	B
62	58	2021-10-17	t	40	A
63	65	2019-07-24	f	30	C
64	97	2022-11-30	t	28	B
65	77	2020-01-01	t	36	A
66	3	2021-02-22	f	22	C
67	31	2019-05-30	t	37	B
68	20	2020-08-26	t	38	A
69	41	2021-07-07	f	26	C
70	16	2022-10-10	t	35	B
71	79	2019-03-29	t	34	A
72	88	2020-02-10	t	30	B
73	12	2021-04-14	t	28	A
74	25	2019-06-05	f	23	C
75	69	2021-09-17	t	29	A
76	83	2019-11-04	t	35	B
77	96	2020-10-31	f	22	C
78	55	2021-05-16	t	40	A
79	61	2019-07-20	t	31	B
80	38	2020-06-28	t	36	A
81	14	2021-02-04	f	24	C
82	75	2020-08-18	t	30	B
83	7	2019-05-15	t	34	A
84	40	2022-01-12	f	23	C
85	92	2020-03-30	t	29	A
86	45	2019-08-23	t	32	B
87	99	2021-11-05	t	31	A
88	2	2020-09-12	t	36	B
89	4	2022-06-10	f	27	C
90	87	2021-01-20	t	40	A
91	6	2019-11-16	t	28	B
92	15	2020-04-19	f	25	C
93	93	2021-03-28	t	39	A
94	1	2022-05-01	t	35	B
95	89	2019-10-14	t	32	A
96	17	2020-02-09	t	28	B
97	100	2021-07-11	f	22	C
98	39	2022-03-21	t	37	A
99	86	2020-11-09	t	30	B
100	49	2021-06-04	f	20	C
\.


--
-- TOC entry 4995 (class 0 OID 17815)
-- Dependencies: 228
-- Data for Name: government_policy; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.government_policy (policy_id, policy_name, policy_type, state_id) FROM stdin;
1	Migration Support Scheme	Migration	1
2	Interstate Migrant Workers Act	Migration	3
3	Bihar Migrant Labour Welfare Program	Migration	4
4	Chhattisgarh Migrant Assistance	Migration	5
5	Goa Migrant Worker Act	Migration	6
6	Gujarat Migrant Welfare Board	Migration	7
7	Haryana Migrant Worker Program	Migration	8
8	Himachal Pradesh Migrant Assistance	Migration	9
9	Jharkhand Migrant Support	Migration	10
10	Karnataka Migrant Worker Policy	Migration	11
11	Kerala Migrant Welfare Program	Migration	12
12	Madhya Pradesh Migration Assistance	Migration	13
13	Maharashtra Migrant Worker Act	Migration	14
14	Odisha Migrant Labour Welfare Scheme	Migration	19
15	Punjab Migrant Support Program	Migration	20
16	Rajasthan Migrant Worker Program	Migration	21
17	Tamil Nadu Migrant Assistance	Migration	23
18	Telangana Migrant Welfare Act	Migration	24
19	West Bengal Migrant Assistance	Migration	28
20	Delhi Migration Support Policy	Migration	33
21	Andhra Pradesh Job Creation Scheme	Job	1
22	Arunachal Pradesh Employment Program	Job	2
23	Assam Job Guarantee Act	Job	3
24	Bihar Skill Development Mission	Job	4
25	Chhattisgarh Employment Opportunity Scheme	Job	5
26	Goa Youth Employment Program	Job	6
27	Gujarat Industrial Job Scheme	Job	7
28	Haryana Skill Development	Job	8
29	Himachal Pradesh Job Assurance Program	Job	9
30	Jharkhand Job Training Scheme	Job	10
31	Karnataka Employment Guarantee	Job	11
32	Kerala Startup Job Program	Job	12
33	Madhya Pradesh Job Creation Mission	Job	13
34	Maharashtra Rural Employment Scheme	Job	14
35	Punjab Employment Guarantee	Job	20
36	Rajasthan Job Training Initiative	Job	21
37	Sikkim Youth Employment Mission	Job	22
38	Tamil Nadu Skill Development	Job	23
39	Uttar Pradesh Job Support Scheme	Job	26
40	West Bengal Employment Mission	Job	28
41	Andhra Pradesh Free Education Scheme	Education	1
42	Assam Scholarship Program	Education	3
43	Bihar Free Tuition Program	Education	4
44	Chhattisgarh Education Loan Scheme	Education	5
45	Goa Student Support Program	Education	6
46	Gujarat Educational Aid Scheme	Education	7
47	Haryana Scholarship Program	Education	8
48	Himachal Pradesh Free Education Act	Education	9
49	Jharkhand Tuition Fee Waiver	Education	10
50	Karnataka Merit Scholarship	Education	11
51	Kerala Student Welfare Scheme	Education	12
52	Madhya Pradesh Scholarship Scheme	Education	13
53	Maharashtra Education Aid Program	Education	14
54	Manipur Free Education Initiative	Education	15
55	Nagaland Scholarship Program	Education	18
56	Odisha Educational Support Scheme	Education	19
57	Punjab Student Welfare Act	Education	20
58	Rajasthan School Support Scheme	Education	21
59	Tamil Nadu Education Assistance	Education	23
60	Uttar Pradesh Merit Scholarship	Education	26
61	Andhra Pradesh Health Insurance Scheme	Health	1
62	Arunachal Pradesh Medical Support	Health	2
63	Assam Health Protection Scheme	Health	3
64	Bihar Health Assurance Plan	Health	4
65	Chhattisgarh Rural Health Initiative	Health	5
66	Goa Free Health Check-up Program	Health	6
67	Gujarat Medical Assistance Scheme	Health	7
68	Haryana Healthcare Program	Health	8
69	Himachal Pradesh Health Initiative	Health	9
70	Jharkhand Rural Health Scheme	Health	10
71	Karnataka Health Insurance Program	Health	11
72	Kerala Healthcare Assistance	Health	12
73	Madhya Pradesh Health Coverage Program	Health	13
74	Maharashtra Health Insurance Act	Health	14
75	Odisha Health and Wellness Program	Health	19
76	Punjab Health Assurance Scheme	Health	20
77	Rajasthan Health Welfare Program	Health	21
78	Tamil Nadu Healthcare Mission	Health	23
79	Uttarakhand Health Insurance Plan	Health	27
80	West Bengal Medical Support Scheme	Health	28
81	Delhi Migrant Welfare Act	Migration	33
82	Jammu and Kashmir Employment Guarantee	Job	35
83	Tripura Free Education Program	Education	25
84	Ladakh Health Support Plan	Health	36
85	Puducherry Skill Development Scheme	Job	34
86	Lakshadweep Student Support Program	Education	32
87	Dadra and Nagar Haveli Job Opportunity Scheme	Job	31
88	Andaman and Nicobar Health Program	Health	29
89	Chandigarh Migrant Assistance Program	Migration	30
90	Sikkim Education for All Initiative	Education	22
91	Mizoram Employment Assistance	Job	17
92	Manipur Education Support Scheme	Education	15
93	Nagaland Healthcare Mission	Health	18
94	Meghalaya Job Training Program	Job	16
95	Kerala Rural Education Fund	Education	12
96	Punjab Migration Assistance	Migration	20
97	Odisha Job Opportunity Scheme	Job	19
98	Tamil Nadu Rural Health Program	Health	23
99	Uttar Pradesh Student Loan Support	Education	26
100	West Bengal Skill Development Initiative	Job	28
\.


--
-- TOC entry 4992 (class 0 OID 17796)
-- Dependencies: 225
-- Data for Name: health_facility; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.health_facility (facility_id, name, facility_type, bed_capacity) FROM stdin;
1	All India Institute of Medical Sciences	Hospital	800
2	Post Graduate Institute of Medical Education and Research	Hospital	1500
3	Tata Memorial Hospital	Cancer Hospital	600
4	Fortis Hospital	Multi-Specialty Hospital	200
5	Apollo Hospitals	Multi-Specialty Hospital	400
6	Max Super Specialty Hospital	Multi-Specialty Hospital	300
7	Narayana Health	Multi-Specialty Hospital	1000
8	Medanta – The Medicity	Multi-Specialty Hospital	800
9	Kokilaben Dhirubhai Ambani Hospital	Multi-Specialty Hospital	300
10	Manipal Hospital	Multi-Specialty Hospital	500
11	Lilavati Hospital	Multi-Specialty Hospital	350
12	Sri Ramachandra Medical Centre	Hospital	700
13	Sankara Nethralaya	Eye Hospital	250
14	P.D. Hinduja Hospital	Multi-Specialty Hospital	300
15	Care Hospital	Multi-Specialty Hospital	350
16	Jaypee Hospital	Multi-Specialty Hospital	200
17	Sitaram Bhartia Institute of Science and Research	Hospital	100
18	HCG Cancer Centre	Cancer Hospital	150
19	Aster CMI Hospital	Multi-Specialty Hospital	250
20	Asian Institute of Medical Sciences	Multi-Specialty Hospital	400
21	Narayana Institute of Cardiac Sciences	Heart Hospital	200
22	Apollo Spectra Hospitals	Surgical Hospital	150
23	Sahyadri Hospital	Multi-Specialty Hospital	300
24	MGM Healthcare	Multi-Specialty Hospital	400
25	MediHope Super Specialty Hospital	Multi-Specialty Hospital	200
26	BLK Super Specialty Hospital	Multi-Specialty Hospital	300
27	Sri Aurobindo Institute of Medical Sciences	Hospital	400
28	Sankalp Hospital	Multi-Specialty Hospital	150
29	Jaslok Hospital	Multi-Specialty Hospital	600
30	Indraprastha Apollo Hospital	Multi-Specialty Hospital	500
31	Hiranandani Hospital	Multi-Specialty Hospital	300
32	Vijaya Medical Centre	Hospital	250
33	Reddy Hospitals	Multi-Specialty Hospital	150
34	Fortis Escorts Heart Institute	Heart Hospital	250
35	Yashoda Hospitals	Multi-Specialty Hospital	400
36	Zydus Hospitals	Multi-Specialty Hospital	200
37	Vivekananda Hospital	Multi-Specialty Hospital	300
38	St. John’s Medical College Hospital	Hospital	500
39	Sanjivani Hospital	Multi-Specialty Hospital	150
40	Bansal Hospital	Multi-Specialty Hospital	200
41	Max Healthcare	Multi-Specialty Hospital	600
42	Wockhardt Hospitals	Multi-Specialty Hospital	350
43	Manipal Comprehensive Cancer Care	Cancer Hospital	150
44	Heritage Hospital	Multi-Specialty Hospital	100
45	Lifecare Hospital	Multi-Specialty Hospital	200
46	Oasis Hospital	Multi-Specialty Hospital	300
47	KIMS Hospital	Multi-Specialty Hospital	500
48	Fortis La Femme Hospital	Women’s Hospital	200
49	St. Thomas Hospital	Hospital	400
50	Shalby Hospitals	Multi-Specialty Hospital	350
51	Health City	Multi-Specialty Hospital	300
52	Cloudnine Hospital	Women’s Hospital	150
53	Sanghvi Hospital	Multi-Specialty Hospital	200
54	Mindsprings Hospital	Psychiatric Hospital	100
55	Sanjeevani Hospital	Multi-Specialty Hospital	300
56	Swastik Hospital	Multi-Specialty Hospital	150
57	Puspa Hospital	Multi-Specialty Hospital	250
58	LifeCare Hospitals	Multi-Specialty Hospital	100
59	Shanti Nursing Home	Nursing Home	50
60	Dr. Lal PathLabs	Diagnostics Center	0
61	Max HealthCare	Multi-Specialty Hospital	600
62	Srinivas Hospital	Multi-Specialty Hospital	200
63	Star Hospitals	Multi-Specialty Hospital	150
64	Siddharth Hospital	Multi-Specialty Hospital	250
65	Care Clinic	Clinic	10
66	Sankalp Nursing Home	Nursing Home	30
67	Karnataka Hospital	Multi-Specialty Hospital	400
68	Shraddha Hospital	Multi-Specialty Hospital	300
69	Prashanth Hospital	Multi-Specialty Hospital	200
70	Radiant Hospital	Multi-Specialty Hospital	100
71	Sarvodaya Hospital	Multi-Specialty Hospital	300
72	Venkateshwara Hospital	Multi-Specialty Hospital	500
73	Kasturba Hospital	Hospital	600
74	Karnavati Hospital	Multi-Specialty Hospital	250
75	Muktai Hospital	Multi-Specialty Hospital	300
76	Vatsalya Hospital	Multi-Specialty Hospital	150
77	Nandini Hospital	Multi-Specialty Hospital	200
78	Gujarat Hospital	Multi-Specialty Hospital	400
79	Patan Hospital	Multi-Specialty Hospital	100
80	Sushrut Hospital	Multi-Specialty Hospital	300
81	Dhanvantri Hospital	Multi-Specialty Hospital	600
82	Universal Hospital	Multi-Specialty Hospital	250
83	Yashoda Cancer Institute	Cancer Hospital	100
84	Jeevan Hospital	Multi-Specialty Hospital	300
85	Om Hospital	Multi-Specialty Hospital	500
86	Gleneagles Global Health City	Multi-Specialty Hospital	700
87	Pyramid Hospital	Multi-Specialty Hospital	200
88	Sai Hospital	Multi-Specialty Hospital	100
89	Shubham Hospital	Multi-Specialty Hospital	200
90	Srinivasa Hospital	Multi-Specialty Hospital	300
91	MediHelp Hospital	Multi-Specialty Hospital	500
92	Eden Hospital	Multi-Specialty Hospital	600
93	Medicure Hospital	Multi-Specialty Hospital	350
94	Columbia Asia Hospital	Multi-Specialty Hospital	400
95	Pushpanjali Hospital	Multi-Specialty Hospital	250
96	Chaitanya Hospital	Multi-Specialty Hospital	100
97	Arogyam Hospital	Multi-Specialty Hospital	300
98	Motherhood Hospital	Women’s Hospital	200
99	Sunshine Hospital	Multi-Specialty Hospital	500
100	Jaypee Hospital	Multi-Specialty Hospital	400
\.


--
-- TOC entry 4988 (class 0 OID 17776)
-- Dependencies: 221
-- Data for Name: institute; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.institute (institution_id, name, tuition_fees, address, website, accreditation_status, established_year, type) FROM stdin;
6	IIM Ahmedabad	250000.00	Ahmedabad, Gujarat	http://www.iima.ac.in	t	1961	Management
86	Kakatiya University	50000.00	Warangal, Telangana	http://www.kakatiya.ac.in	t	1976	Multidisciplinary
72	Karnataka State Open University	40000.00	Mysuru, Karnataka	http://www.ksoumysore.karnataka.gov.in	t	1996	Open University
85	Kochi University of Science and Technology	70000.00	Kochi, Kerala	http://www.kust.edu.in	t	1993	Technology
96	Guru Nanak Dev Engineering College	70000.00	Ludhiana, Punjab	http://www.gndec.ac.in	t	1956	Engineering
67	Indian Institute of Technology, Dhanbad	200000.00	Dhanbad, Jharkhand	http://www.iitism.ac.in	t	1926	Technology
26	Banaras Hindu University	50000.00	Varanasi, Uttar Pradesh	http://www.bhu.ac.in	t	1916	Arts
16	Shiv Nadar University	180000.00	Greater Noida, Uttar Pradesh	http://www.snu.edu.in	t	2011	Technology
25	Amity University	100000.00	Noida, Uttar Pradesh	http://www.amity.edu	t	2005	Multidisciplinary
35	Shivaji University	40000.00	Kolhapur, Maharashtra	http://www.unishivaji.ac.in	t	1962	Multidisciplinary
79	Shivaji University	40000.00	Kolhapur, Maharashtra	http://www.unishivaji.ac.in	t	1962	Multidisciplinary
45	Mahatma Gandhi University	50000.00	Kottayam, Kerala	http://www.mgu.ac.in	t	1983	Multidisciplinary
5	IIT Kharagpur	200000.00	Kharagpur, West Bengal	http://www.iitkgp.ac.in	t	1951	Technology
7	IIM Bangalore	250000.00	Bangalore, Karnataka	http://www.iimb.ac.in	t	1973	Management
33	IIIT Bangalore	120000.00	Bangalore, Karnataka	http://www.iiitb.ac.in	t	1999	Technology
47	REVA University	60000.00	Bangalore, Karnataka	http://www.reva.edu.in	t	2012	Technology
49	M S Ramaiah University	80000.00	Bangalore, Karnataka	http://www.msruas.ac.in	t	2013	Technology
59	National Law School of India University	80000.00	Bangalore, Karnataka	http://www.nls.ac.in	t	1987	Law
10	NIT Trichy	120000.00	Tiruchirappalli, Tamil Nadu	http://www.nitt.edu	t	1971	Technology
11	NIT Surathkal	120000.00	Surathkal, Karnataka	http://www.nitk.ac.in	t	1960	Technology
12	VIT Vellore	200000.00	Vellore, Tamil Nadu	http://www.vit.ac.in	t	1984	Technology
48	Vellore Institute of Technology	200000.00	Vellore, Tamil Nadu	http://www.vit.ac.in	t	1984	Technology
14	Manipal Institute of Technology	120000.00	Manipal, Karnataka	http://www.manipal.edu	t	1957	Technology
15	LPU	80000.00	Phagwara, Punjab	http://www.lpu.in	t	2009	Technology
36	Lovely Professional University	80000.00	Phagwara, Punjab	http://www.lpu.in	t	2009	Multidisciplinary
29	SASTRA University	120000.00	Thanjavur, Tamil Nadu	http://www.sastra.edu	t	1984	Technology
51	SASTRA University	120000.00	Thanjavur, Tamil Nadu	http://www.sastra.edu.in	t	1984	Technology
32	Birla Institute of Technology	120000.00	Mesra, Jharkhand	http://www.bitmesra.ac.in	t	1955	Technology
34	Krea University	160000.00	Sri City, Andhra Pradesh	http://www.krea.edu.in	t	2018	Multidisciplinary
39	NIIT University	70000.00	Neemrana, Rajasthan	http://www.niituniversity.in	t	2009	Technology
42	Bharati Vidyapeeth University	70000.00	Pune, Maharashtra	http://www.bvuniversity.edu.in	t	1964	Multidisciplinary
52	Bharti Vidyapeeth Deemed University	70000.00	Pune, Maharashtra	http://www.bvdu.edu.in	t	1996	Multidisciplinary
46	Chandigarh University	60000.00	Gharuan, Punjab	http://www.cuchd.in	t	2012	Multidisciplinary
89	Andhra University	60000.00	Visakhapatnam, Andhra Pradesh	http://www.andhrauniversity.edu.in	t	1926	Multidisciplinary
30	K L University	80000.00	Vijayawada, Andhra Pradesh	http://www.kluniversity.in	t	1980	Technology
92	Gauhati University	60000.00	Guwahati, Assam	http://www.gauhati.ac.in	t	1948	Multidisciplinary
24	National Institute of Design	120000.00	Ahmedabad, Gujarat	http://www.nid.edu	t	1961	Design
31	Nirma University	80000.00	Ahmedabad, Gujarat	http://www.nirmauni.ac.in	t	2003	Technology
60	National Institute of Design	120000.00	Ahmedabad, Gujarat	http://www.nid.edu	t	1961	Design
74	Nirma University	80000.00	Ahmedabad, Gujarat	http://www.nirmauni.ac.in	t	2003	Technology
68	Indian Institute of Management, Ranchi	250000.00	Ranchi, Jharkhand	http://www.iimranchi.ac.in	t	2010	Management
76	Ranchi University	50000.00	Ranchi, Jharkhand	http://www.ranchiuniversity.ac.in	t	1960	Multidisciplinary
82	University of Kerala	60000.00	Thiruvananthapuram, Kerala	http://www.keralauniversity.ac.in	t	1937	Multidisciplinary
100	National Institute of Technical Teachers Training and Research	60000.00	Bhopal, Madhya Pradesh	http://www.nitttrbpl.ac.in	t	2002	Technical Teaching
21	Tata Institute of Social Sciences	70000.00	Mumbai, Maharashtra	http://www.tiss.edu	t	1936	Social Sciences
27	University of Mumbai	60000.00	Mumbai, Maharashtra	http://www.mu.ac.in	t	1857	Multidisciplinary
1	IIT Bombay	200000.00	Mumbai, Maharashtra	http://www.iitb.ac.in	t	1958	Technology
75	Narsee Monjee Institute of Management Studies	80000.00	Mumbai, Maharashtra	http://www.nmims.edu	t	1994	Management
80	Tata Institute of Fundamental Research	70000.00	Mumbai, Maharashtra	http://www.tifr.res.in	t	1945	Research
90	Utkal University	60000.00	Bhubaneswar, Odisha	http://utkaluniversity.ac.in	t	1943	Multidisciplinary
20	Panjab University	50000.00	Chandigarh	http://www.puchd.ac.in	t	1882	Arts
97	Punjab Engineering College	70000.00	Chandigarh	http://www.pec.ac.in	t	1953	Engineering
57	Manipal University Jaipur	70000.00	Jaipur, Rajasthan	http://www.muj.manipal.edu	t	2011	Technology
54	Sikkim Manipal University	70000.00	Gangtok, Sikkim	http://www.smu.edu.in	t	1995	Multidisciplinary
3	IIT Madras	200000.00	Chennai, Tamil Nadu	http://www.iitm.ac.in	t	1959	Technology
13	SRM Institute of Science and Technology	150000.00	Chennai, Tamil Nadu	http://www.srmist.edu.in	t	1985	Technology
28	University of Chennai	50000.00	Chennai, Tamil Nadu	http://www.unom.ac.in	t	1857	Multidisciplinary
50	SRM Institute of Science and Technology	150000.00	Chennai, Tamil Nadu	http://www.srmuniv.ac.in	t	1985	Technology
56	Jawaharlal Nehru Technological University	50000.00	Hyderabad, Telangana	http://www.jntuh.ac.in	t	1972	Technology
71	Indian School of Business	250000.00	Hyderabad, Telangana	http://www.isb.edu	t	2001	Management
99	Jawaharlal Nehru University, Hyderabad	60000.00	Hyderabad, Telangana	http://www.jnuhyd.ac.in	t	2009	Multidisciplinary
69	Indian Institute of Management, Lucknow	250000.00	Lucknow, Uttar Pradesh	http://www.iiml.ac.in	t	1984	Management
87	Dr. B.R. Ambedkar University	60000.00	Lucknow, Uttar Pradesh	http://www.dbrau.ac.in	t	2007	Multidisciplinary
41	UPES	80000.00	Dehradun, Uttarakhand	http://www.upes.ac.in	t	2003	Technology
8	IIM Calcutta	250000.00	Kolkata, West Bengal	http://www.iimcal.ac.in	t	1961	Management
22	Indian Statistical Institute	60000.00	Kolkata, West Bengal	http://www.isical.ac.in	t	1931	Statistics
37	Jadavpur University	60000.00	Kolkata, West Bengal	http://www.jaduniv.edu.in	t	1955	Multidisciplinary
55	University of Calcutta	60000.00	Kolkata, West Bengal	http://www.caluniv.ac.in	t	1857	Multidisciplinary
2	IIT Delhi	200000.00	New Delhi	http://www.iitd.ac.in	t	1961	Technology
17	Delhi University	50000.00	New Delhi	http://www.du.ac.in	t	1922	Arts
18	Jawaharlal Nehru University	60000.00	New Delhi	http://www.jnu.ac.in	t	1969	Arts
19	Jamia Millia Islamia	70000.00	New Delhi	http://www.jmi.ac.in	t	1920	Arts
23	National Institute of Fashion Technology	120000.00	New Delhi	http://www.nift.ac.in	t	1986	Fashion Design
38	GGS Indraprastha University	50000.00	New Delhi	http://www.ipu.ac.in	t	1998	Multidisciplinary
43	Delhi Technological University	60000.00	New Delhi	http://www.dtu.ac.in	t	1941	Technology
44	Netaji Subhas University of Technology	60000.00	New Delhi	http://www.nsut.ac.in	t	1983	Technology
58	Shri Ram College of Commerce	50000.00	New Delhi	http://www.srcc.edu.in	t	1926	Commerce
61	National Institute of Fashion Technology	120000.00	New Delhi	http://www.nift.ac.in	t	1986	Fashion
62	Jamia Hamdard	60000.00	New Delhi	http://www.jamiahamdard.edu	t	1989	Health Sciences
63	Hamdard University	60000.00	New Delhi	http://www.hamdard.edu	t	1989	Health Sciences
81	University of Delhi	50000.00	New Delhi	http://www.du.ac.in	t	1922	Multidisciplinary
40	PDPU	60000.00	Gandhinagar, Gujarat	http://www.pdpu.ac.in	t	2007	Technology
53	Amrita Vishwa Vidyapeetham	100000.00	Coimbatore, Tamil Nadu	http://www.amrita.edu	t	2003	Multidisciplinary
83	Bharathiar University	60000.00	Coimbatore, Tamil Nadu	http://www.b-u.ac.in	t	1982	Multidisciplinary
94	Tamil Nadu Agricultural University	60000.00	Coimbatore, Tamil Nadu	http://www.tnau.ac.in	t	1971	Agricultural
64	Indian Institute of Technology, Mandi	200000.00	Mandi, Himachal Pradesh	http://www.iitmandi.ac.in	t	2009	Technology
65	Indian Institute of Technology, Bhilai	200000.00	Bhilai, Chhattisgarh	http://www.iitbhilai.ac.in	t	2016	Technology
4	IIT Kanpur	200000.00	Kanpur, Uttar Pradesh	http://www.iitk.ac.in	t	1959	Technology
9	BITS Pilani	150000.00	Pilani, Rajasthan	http://www.bits-pilani.ac.in	t	1964	Technology
66	Indian Institute of Technology, Jammu	200000.00	Jammu, Jammu and Kashmir	http://www.iitjammu.ac.in	t	2016	Technology
77	University of Jammu	60000.00	Jammu, Jammu and Kashmir	http://www.jammuuniversity.in	t	1969	Multidisciplinary
70	Indian Institute of Management, Kozhikode	250000.00	Kozhikode, Kerala	http://www.iimk.ac.in	t	1997	Management
73	Mahatma Gandhi Antarrashtriya Hindi Vishwavidyalaya	60000.00	Wardha, Maharashtra	http://www.hindivishwa.org	t	1997	Language
78	Sardar Patel University	60000.00	Vallabh Vidyanagar, Gujarat	http://www.spuvvn.edu	t	1955	Multidisciplinary
84	Vidyasagar University	60000.00	Midnapore, West Bengal	http://www.vidyasagar.ac.in	t	1981	Multidisciplinary
88	Saurashtra University	60000.00	Rajkot, Gujarat	http://www.saurashtrauniversity.edu	t	1967	Multidisciplinary
91	Baba Farid University of Health Sciences	70000.00	Faridkot, Punjab	http://www.bfuhs.ac.in	t	1998	Health Sciences
93	Periyar University	60000.00	Salem, Tamil Nadu	http://www.periyaruniversity.ac.in	t	1997	Multidisciplinary
95	Jawaharlal Nehru Technological University, Kakinada	60000.00	Kakinada, Andhra Pradesh	http://www.jntuk.edu.in	t	1946	Technology
98	Sardar Vallabhbhai Patel Institute of Technology	60000.00	Vasad, Gujarat	http://www.svpit.ac.in	t	2009	Technology
110	Test University	50000.00	123 University Street	https://testuniversity.edu	t	2020	Technology
\.


--
-- TOC entry 5003 (class 0 OID 17892)
-- Dependencies: 236
-- Data for Name: migration_event; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migration_event (migration_id, youngster_id, duration, from_region, to_region, migration_date) FROM stdin;
1	1	5	5	10	2018-03-15
2	2	12	20	15	2019-06-25
3	3	18	25	30	2021-11-05
4	1	9	35	40	2020-08-10
5	5	6	10	45	2015-09-12
6	6	14	50	55	2017-01-20
7	7	11	60	65	2022-02-28
8	8	7	70	75	2020-12-01
9	9	15	80	85	2016-04-17
10	10	19	90	95	2023-07-22
11	1	10	100	105	2014-10-14
12	12	17	110	115	2019-05-19
13	13	13	120	125	2022-09-30
14	14	8	130	135	2021-03-11
15	15	16	140	1	2015-06-09
16	16	4	2	6	2017-02-05
17	17	5	3	9	2024-01-01
18	18	7	4	14	2020-11-11
19	19	9	5	16	2018-03-22
20	20	18	6	18	2019-07-15
21	21	3	7	20	2022-12-12
22	22	10	8	21	2016-09-25
23	23	15	9	23	2014-04-30
24	24	12	10	24	2023-05-05
25	25	8	11	26	2022-08-18
26	26	11	12	28	2015-11-09
27	27	2	13	30	2018-10-14
28	28	6	14	32	2019-02-20
29	29	14	15	34	2021-01-05
30	30	5	16	36	2020-03-10
31	31	17	17	38	2016-06-21
32	32	19	18	40	2022-07-01
33	33	3	19	41	2015-08-28
34	34	8	20	42	2024-03-15
35	35	7	21	44	2018-01-10
36	36	10	22	46	2017-04-12
37	37	12	23	48	2023-10-30
38	38	6	24	50	2020-11-15
39	39	14	25	52	2019-12-22
40	40	11	26	54	2015-03-17
41	41	8	27	56	2021-05-08
42	42	10	28	58	2022-02-18
43	43	9	29	60	2014-10-12
44	44	7	30	62	2023-04-05
45	45	6	31	63	2017-08-15
46	46	4	32	64	2018-01-25
47	47	2	33	66	2022-06-09
48	48	10	34	67	2016-09-13
49	49	5	35	68	2015-02-20
50	50	11	36	69	2019-10-18
51	51	7	37	70	2021-03-14
52	52	9	38	72	2020-11-05
53	53	13	39	74	2019-09-12
54	54	14	40	75	2016-03-22
55	55	8	41	76	2018-09-11
56	56	11	42	78	2019-11-20
57	57	15	43	80	2023-05-30
58	58	10	44	81	2017-06-12
59	59	12	45	83	2020-12-08
60	60	6	46	84	2021-01-29
61	61	4	47	85	2019-04-18
62	62	13	48	86	2015-10-22
63	63	14	49	87	2022-07-01
64	64	5	50	88	2016-02-14
65	65	8	51	89	2023-03-15
66	66	6	52	90	2019-09-12
67	67	11	53	91	2015-08-25
68	68	18	54	92	2020-11-05
69	69	9	55	93	2021-04-18
70	70	15	56	94	2017-01-29
71	71	3	57	95	2023-01-15
72	72	2	58	96	2018-03-01
73	73	4	59	97	2015-12-17
74	74	10	60	98	2019-05-22
75	75	12	61	99	2020-07-28
76	76	8	62	100	2014-09-15
77	77	6	63	101	2022-11-30
78	78	14	64	102	2021-02-25
79	79	11	65	103	2018-04-30
80	80	7	66	104	2016-08-02
81	81	5	67	105	2014-12-21
82	82	10	68	106	2021-07-30
83	83	12	69	107	2017-05-09
84	84	9	70	108	2019-09-23
85	85	3	71	109	2022-02-10
86	86	14	72	110	2015-01-15
87	87	6	73	111	2021-03-30
88	88	13	74	112	2020-05-17
89	89	11	75	113	2016-06-19
90	90	10	76	114	2019-07-01
91	91	17	77	115	2023-08-05
92	92	4	78	116	2021-04-18
93	93	14	79	117	2017-10-20
94	94	15	80	118	2018-12-15
95	95	6	81	119	2020-02-01
96	96	12	82	120	2015-11-17
97	97	8	83	121	2022-09-30
98	98	9	84	122	2023-01-10
99	99	11	85	123	2019-05-12
100	100	3	86	124	2020-11-01
101	1	19	87	125	2022-03-20
102	2	17	88	126	2020-10-15
103	3	10	89	127	2018-06-25
104	4	5	90	128	2016-08-14
105	5	8	91	129	2022-11-19
106	6	12	92	130	2021-07-09
107	7	10	93	131	2014-04-10
108	8	9	94	132	2019-02-23
109	9	6	95	133	2018-12-09
110	10	4	96	134	2021-11-20
111	11	2	97	135	2017-03-25
112	12	16	98	136	2020-12-03
113	13	13	99	137	2023-06-30
114	14	11	100	138	2018-05-15
115	15	19	101	139	2019-07-11
116	16	5	102	140	2022-03-04
117	17	10	103	1	2021-10-19
118	18	6	104	2	2016-08-28
119	19	3	105	3	2022-12-22
120	20	9	106	4	2023-05-14
121	21	8	107	5	2015-11-29
122	22	17	108	6	2019-03-16
123	23	4	109	7	2018-02-19
124	24	12	110	8	2022-08-12
125	25	6	111	9	2017-09-25
126	26	18	112	10	2019-04-05
127	27	5	113	11	2020-07-23
128	28	11	114	12	2016-10-15
129	29	9	115	13	2021-01-18
130	30	3	116	14	2023-06-09
131	31	4	117	15	2018-08-17
132	32	7	118	16	2020-01-10
133	33	6	119	17	2015-11-30
134	34	13	120	18	2022-10-14
135	35	17	121	19	2019-12-01
136	36	15	122	20	2023-03-11
137	37	14	123	21	2020-10-07
138	38	12	124	22	2016-04-20
139	39	8	125	23	2021-05-30
140	40	5	126	24	2015-07-15
141	41	9	127	25	2018-09-19
142	42	11	128	26	2022-01-25
143	43	10	129	27	2019-10-15
144	44	8	130	28	2016-11-08
145	45	6	131	29	2021-06-10
146	46	7	132	30	2020-12-12
147	47	14	133	31	2022-08-21
148	48	3	134	32	2015-04-01
149	49	2	135	33	2019-05-17
150	50	1	136	34	2023-02-02
\.


--
-- TOC entry 5005 (class 0 OID 17906)
-- Dependencies: 238
-- Data for Name: opportunities; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.opportunities (opportunity_id, opportunity_type, location, employer_id, salary_benefits, eligibility_criteria) FROM stdin;
1	Internship	Mumbai	56	₹15,000 per month	Undergraduate
2	Full-time	Delhi	23	₹60,000 per month	Postgraduate
3	Part-time	Bangalore	89	₹25,000 per month	Undergraduate
4	Contract	Hyderabad	45	₹50,000 per month	Any Graduate
5	Freelance	Chennai	78	Project-based	Experience preferred
6	Internship	Kolkata	34	₹12,000 per month	Undergraduate
7	Full-time	Pune	91	₹70,000 per month	Postgraduate
8	Part-time	Ahmedabad	10	₹20,000 per month	Diploma
9	Contract	Jaipur	82	₹55,000 per month	Postgraduate
10	Freelance	Lucknow	37	Project-based	Experience preferred
11	Internship	Surat	66	₹18,000 per month	Undergraduate
12	Full-time	Nagpur	53	₹62,000 per month	Postgraduate
14	Contract	Visakhapatnam	18	₹48,000 per month	Experience preferred
15	Freelance	Vijayawada	84	Project-based	Undergraduate
16	Internship	Indore	30	₹14,000 per month	Undergraduate
17	Full-time	Mysore	72	₹68,000 per month	Postgraduate
18	Part-time	Nashik	4	₹21,000 per month	Any Graduate
19	Contract	Aurangabad	60	₹53,000 per month	Postgraduate
20	Freelance	Rajkot	26	Project-based	Experience preferred
21	Internship	Vadodara	77	₹16,000 per month	Undergraduate
22	Full-time	Patna	11	₹64,000 per month	Postgraduate
23	Part-time	Bhopal	49	₹24,000 per month	Any Graduate
24	Contract	Gwalior	67	₹57,000 per month	Experience preferred
25	Freelance	Agra	93	Project-based	Undergraduate
26	Internship	Dehradun	32	₹15,000 per month	Undergraduate
27	Full-time	Ranchi	90	₹69,000 per month	Postgraduate
28	Part-time	Srinagar	2	₹23,000 per month	Any Graduate
29	Contract	Jammu	54	₹52,000 per month	Postgraduate
30	Freelance	Shimla	71	Project-based	Experience preferred
31	Internship	Gangtok	16	₹17,000 per month	Undergraduate
32	Full-time	Imphal	14	₹65,000 per month	Postgraduate
33	Part-time	Aizawl	88	₹20,000 per month	Any Graduate
34	Contract	Kohima	40	₹49,000 per month	Experience preferred
35	Freelance	Itanagar	41	Project-based	Undergraduate
36	Internship	Agartala	86	₹13,000 per month	Undergraduate
37	Full-time	Dibrugarh	29	₹63,000 per month	Postgraduate
38	Part-time	Guwahati	1	₹22,000 per month	Any Graduate
39	Contract	Tawang	33	₹50,000 per month	Postgraduate
40	Freelance	Silchar	5	Project-based	Experience preferred
41	Internship	Tezpur	70	₹19,000 per month	Undergraduate
42	Full-time	Tirupati	87	₹66,000 per month	Postgraduate
43	Part-time	Kakinada	75	₹25,000 per month	Any Graduate
44	Contract	Vellore	57	₹56,000 per month	Postgraduate
45	Freelance	Tirunelveli	46	Project-based	Experience preferred
46	Internship	Thiruvananthapuram	39	₹18,000 per month	Undergraduate
47	Full-time	Nellore	65	₹61,000 per month	Postgraduate
48	Part-time	Tiruvallur	38	₹22,500 per month	Any Graduate
49	Contract	Chennai	48	₹58,000 per month	Postgraduate
50	Freelance	Madurai	79	Project-based	Experience preferred
51	Internship	Puducherry	42	₹16,500 per month	Undergraduate
52	Full-time	Kozhikode	12	₹67,000 per month	Postgraduate
53	Part-time	Kottayam	3	₹24,500 per month	Any Graduate
54	Contract	Kannur	74	₹52,500 per month	Postgraduate
55	Freelance	Malappuram	97	Project-based	Experience preferred
56	Internship	Ernakulam	73	₹15,500 per month	Undergraduate
57	Full-time	Palakkad	8	₹64,500 per month	Postgraduate
58	Part-time	Idukki	15	₹21,500 per month	Any Graduate
59	Contract	Pathanamthitta	50	₹54,500 per month	Postgraduate
60	Freelance	Thiruvananthapuram	44	Project-based	Experience preferred
61	Internship	Trivandrum	35	₹18,500 per month	Undergraduate
62	Full-time	Thiruvananthapuram	20	₹66,500 per month	Postgraduate
63	Part-time	Chengannur	80	₹23,500 per month	Any Graduate
64	Contract	Muvattupuzha	68	₹58,500 per month	Postgraduate
65	Freelance	Kottayam	27	Project-based	Experience preferred
66	Internship	Alappuzha	24	₹15,800 per month	Undergraduate
67	Full-time	Kollam	61	₹65,800 per month	Postgraduate
68	Part-time	Kottayam	83	₹22,800 per month	Any Graduate
69	Contract	Thodupuzha	92	₹52,800 per month	Postgraduate
70	Freelance	Punalur	6	Project-based	Experience preferred
71	Internship	Neyyattinkara	69	₹17,200 per month	Undergraduate
73	Part-time	Varkala	71	₹24,200 per month	Any Graduate
74	Contract	Kumarakom	88	₹57,200 per month	Postgraduate
75	Freelance	Adoor	25	Project-based	Experience preferred
76	Internship	Mumbai	45	₹16,500 per month	Undergraduate
77	Full-time	Delhi	29	₹63,000 per month	Postgraduate
78	Part-time	Bangalore	19	₹23,000 per month	Any Graduate
79	Contract	Hyderabad	82	₹51,000 per month	Postgraduate
80	Freelance	Chennai	36	Project-based	Experience preferred
81	Internship	Kolkata	53	₹15,200 per month	Undergraduate
82	Full-time	Pune	74	₹72,000 per month	Postgraduate
83	Part-time	Ahmedabad	18	₹19,500 per month	Diploma
84	Contract	Jaipur	55	₹56,000 per month	Postgraduate
85	Freelance	Lucknow	66	Project-based	Experience preferred
86	Internship	Surat	12	₹14,500 per month	Undergraduate
87	Full-time	Nagpur	87	₹65,000 per month	Postgraduate
88	Part-time	Coimbatore	34	₹21,000 per month	Any Graduate
89	Contract	Visakhapatnam	48	₹50,500 per month	Experience preferred
90	Freelance	Vijayawada	26	Project-based	Undergraduate
91	Internship	Indore	38	₹16,000 per month	Undergraduate
92	Full-time	Mysore	44	₹67,500 per month	Postgraduate
93	Part-time	Nashik	10	₹22,000 per month	Any Graduate
94	Contract	Aurangabad	30	₹54,000 per month	Postgraduate
95	Freelance	Rajkot	52	Project-based	Experience preferred
96	Internship	Vadodara	23	₹15,500 per month	Undergraduate
97	Full-time	Patna	9	₹61,500 per month	Postgraduate
98	Part-time	Bhopal	20	₹24,000 per month	Any Graduate
99	Contract	Gwalior	32	₹57,500 per month	Experience preferred
100	Freelance	Agra	78	Project-based	Undergraduate
101	Internship	Dehradun	67	₹16,000 per month	Undergraduate
102	Full-time	Ranchi	25	₹66,500 per month	Postgraduate
103	Part-time	Srinagar	5	₹20,500 per month	Any Graduate
104	Contract	Jammu	40	₹53,000 per month	Postgraduate
105	Freelance	Shimla	49	Project-based	Experience preferred
106	Internship	Gangtok	31	₹13,500 per month	Undergraduate
107	Full-time	Imphal	37	₹62,500 per month	Postgraduate
108	Part-time	Aizawl	11	₹18,000 per month	Any Graduate
109	Contract	Kohima	21	₹52,000 per month	Experience preferred
110	Freelance	Itanagar	33	Project-based	Undergraduate
111	Internship	Agartala	42	₹12,000 per month	Undergraduate
112	Full-time	Dibrugarh	16	₹64,000 per month	Postgraduate
113	Part-time	Guwahati	6	₹23,000 per month	Any Graduate
114	Contract	Tawang	54	₹50,500 per month	Postgraduate
115	Freelance	Silchar	77	Project-based	Experience preferred
116	Internship	Tezpur	8	₹17,000 per month	Undergraduate
117	Full-time	Tirupati	41	₹68,500 per month	Postgraduate
118	Part-time	Kakinada	47	₹25,000 per month	Any Graduate
119	Contract	Vellore	15	₹55,000 per month	Postgraduate
120	Freelance	Tirunelveli	35	Project-based	Experience preferred
121	Internship	Thiruvananthapuram	56	₹17,500 per month	Undergraduate
122	Full-time	Nellore	64	₹59,500 per month	Postgraduate
123	Part-time	Tiruvallur	59	₹20,800 per month	Any Graduate
124	Contract	Chennai	71	₹53,500 per month	Postgraduate
125	Freelance	Madurai	63	Project-based	Experience preferred
126	Internship	Puducherry	73	₹15,000 per month	Undergraduate
127	Full-time	Kozhikode	19	₹60,000 per month	Postgraduate
128	Part-time	Kottayam	22	₹21,500 per month	Any Graduate
129	Contract	Kannur	17	₹55,500 per month	Postgraduate
130	Freelance	Malappuram	84	Project-based	Experience preferred
131	Internship	Ernakulam	66	₹14,000 per month	Undergraduate
132	Full-time	Palakkad	43	₹62,000 per month	Postgraduate
133	Part-time	Idukki	58	₹19,800 per month	Any Graduate
134	Contract	Pathanamthitta	85	₹54,500 per month	Postgraduate
135	Freelance	Thiruvananthapuram	75	Project-based	Experience preferred
136	Internship	Trivandrum	13	₹13,800 per month	Undergraduate
137	Full-time	Thiruvananthapuram	80	₹63,000 per month	Postgraduate
138	Part-time	Chengannur	27	₹20,500 per month	Any Graduate
139	Contract	Muvattupuzha	39	₹54,000 per month	Postgraduate
140	Freelance	Kottayam	93	Project-based	Experience preferred
141	Internship	Alappuzha	57	₹12,800 per month	Undergraduate
142	Full-time	Kollam	2	₹59,000 per month	Postgraduate
143	Part-time	Kottayam	24	₹19,500 per month	Any Graduate
144	Contract	Thodupuzha	51	₹50,800 per month	Postgraduate
145	Freelance	Punalur	36	Project-based	Experience preferred
146	Internship	Neyyattinkara	79	₹15,500 per month	Undergraduate
147	Full-time	Munnar	60	₹61,500 per month	Postgraduate
148	Part-time	Varkala	28	₹24,800 per month	Any Graduate
149	Contract	Kumarakom	69	₹52,300 per month	Postgraduate
150	Freelance	Adoor	62	Project-based	Experience preferred
151	Internship	Mumbai	70	₹15,000 per month	Undergraduate
152	Full-time	Delhi	3	₹68,000 per month	Postgraduate
153	Part-time	Bangalore	4	₹25,000 per month	Any Graduate
154	Contract	Hyderabad	14	₹49,500 per month	Postgraduate
155	Freelance	Chennai	95	Project-based	Experience preferred
156	Internship	Kolkata	91	₹12,500 per month	Undergraduate
157	Full-time	Pune	7	₹70,500 per month	Postgraduate
158	Part-time	Ahmedabad	94	₹19,200 per month	Diploma
159	Contract	Jaipur	46	₹56,500 per month	Postgraduate
160	Freelance	Lucknow	61	Project-based	Experience preferred
161	Internship	Surat	50	₹15,800 per month	Undergraduate
162	Full-time	Nagpur	68	₹63,500 per month	Postgraduate
\.


--
-- TOC entry 4984 (class 0 OID 17753)
-- Dependencies: 217
-- Data for Name: state; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.state (state_id, state_name) FROM stdin;
1	Andhra Pradesh
2	Arunachal Pradesh
3	Assam
4	Bihar
5	Chhattisgarh
6	Goa
7	Gujarat
8	Haryana
9	Himachal Pradesh
10	Jharkhand
11	Karnataka
12	Kerala
13	Madhya Pradesh
14	Maharashtra
15	Manipur
16	Meghalaya
17	Mizoram
18	Nagaland
19	Odisha
20	Punjab
21	Rajasthan
22	Sikkim
23	Tamil Nadu
24	Telangana
25	Tripura
26	Uttar Pradesh
27	Uttarakhand
28	West Bengal
29	Andaman and Nicobar Islands
30	Chandigarh
31	Dadra and Nagar Haveli and Daman and Diu
32	Lakshadweep
33	Delhi
34	Puducherry
35	Jammu and Kashmir
36	Ladakh
\.


--
-- TOC entry 4997 (class 0 OID 17842)
-- Dependencies: 230
-- Data for Name: youngster; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.youngster (youngster_id, name, email, gender, education_id, employment_id, place_of_origin, date_of_birth) FROM stdin;
8	Diya Mehta	diya.mehta@gmail.com	Female	89	8	Surat	1999-08-12
23	Devendra Rao	devendra.rao@gmail.com	Male	54	23	Thane	1998-11-30
32	Aastha Shah	aastha.shah@gmail.com	Female	53	32	Bhavnagar	1999-08-15
41	Vivek Reddy	vivek.reddy@gmail.com	Male	52	41	Gurgaon	2000-05-20
42	Pragya Kapoor	pragya.kapoor@gmail.com	Female	63	42	Meerut	1995-06-25
48	Sakshi Singh	saakshi.singh@gmail.com	Female	29	48	Surat	1997-12-01
16	Tara Rani	tara.rani@gmail.com	Female	77	16	Vadodara	1999-04-30
17	Karan Singh	karan.singh@gmail.com	Male	88	17	Indore	1995-05-22
18	Aditi Gupta	aditi.gupta@gmail.com	Female	99	18	Rajkot	1998-06-15
19	Omkar Patil	omkar.patil@gmail.com	Male	10	19	Nashik	2000-07-01
20	Riya Sharma	riya.sharma@gmail.com	Female	21	20	Faridabad	1997-08-12
21	Aravind Iyer	aravind.iyer@gmail.com	Male	32	21	Mysuru	1996-09-25
22	Vaishali Yadav	vaishali.yadav@gmail.com	Female	43	22	Bhopal	1999-10-14
24	Simran Khanna	simran.khanna@gmail.com	Female	65	24	Jodhpur	1994-12-05
25	Nitin Malhotra	nitin.malhotra@gmail.com	Male	76	25	Dehradun	1999-01-20
26	Preeti Chawla	preeti.chawla@gmail.com	Female	87	26	Agra	1996-02-10
27	Ravi Kumar	ravi.kumar@gmail.com	Male	98	27	Raipur	2000-03-15
28	Tanvi Jain	tanvi.jain@gmail.com	Female	9	28	Mangalore	1995-04-18
29	Harsh Mehta	harsh.mehta@gmail.com	Male	20	29	Guwahati	2002-05-25
30	Sonal Gupta	sonal.gupta@gmail.com	Female	31	30	Chandigarh	1998-06-10
31	Neeraj Gupta	neeraj.gupta@gmail.com	Male	42	31	Srinagar	1997-07-01
33	Mohan Tiwari	mohan.tiwari@gmail.com	Male	64	33	Bhubaneswar	1996-09-10
34	Sonali Roy	sonali.roy@gmail.com	Female	75	34	Patna	1998-10-20
35	Ajay Joshi	ajay.joshi@gmail.com	Male	86	35	Navi Mumbai	1995-11-05
36	Pinky Sharma	pinky.sharma@gmail.com	Female	97	36	Chennai	2001-12-25
37	Rishabh Sharma	rishabh.sharma@gmail.com	Male	8	37	Noida	1998-01-30
38	Tanya Verma	tanya.verma@gmail.com	Female	19	38	Lucknow	1999-02-15
39	Deepak Singh	deepak.singh@gmail.com	Male	30	39	Ghaziabad	1997-03-05
40	Neha Bansal	neha.bansal@gmail.com	Female	41	40	Faridabad	1996-04-22
43	Sidharth Kumar	sidharth.kumar@gmail.com	Male	74	43	Indore	1998-07-15
44	Riya Mehta	riya.mehta@gmail.com	Female	85	44	Kochi	1999-08-30
45	Aakash Iyer	aakash.iyer@gmail.com	Male	96	45	Nashik	1996-09-05
46	Deepika Agarwal	deepika.agarwal@gmail.com	Female	7	46	Jodhpur	1999-10-11
47	Rahul Sharma	raahul.sharma@gmail.com	Male	18	47	Jaipur	1998-11-20
49	Karan Yadav	karan.yadav@gmail.com	Male	40	49	Delhi	1995-01-15
50	Megha Nair	megha.nair@gmail.com	Female	51	50	Bangalore	1999-02-20
51	Shivam Patel	shivam.patel@gmail.com	Male	62	51	Ahmedabad	1996-03-22
52	Aditi Verma	aditi.verma@gmail.com	Female	73	52	Pune	1998-04-25
53	Manoj Kumar	manoj.kumar@gmail.com	Male	84	53	Mumbai	2000-05-30
54	Priya Jain	priya.jain@gmail.com	Female	95	54	Kolkata	1997-06-28
55	Vikas Reddy	vikas.reddy@gmail.com	Male	6	55	Chennai	1998-07-10
56	Simran Kaur	simran.kaur@gmail.com	Female	17	56	Coimbatore	1996-08-15
57	Kunal Gupta	kunal.gupta@gmail.com	Male	28	57	Hyderabad	1999-09-12
58	Neha Rani	neha.rani@gmail.com	Female	39	58	Nagpur	2000-10-19
59	Ravi Kumar	ravii.kumar@gmail.com	Male	50	59	Ahmedabad	1998-11-25
60	Shreya Singh	shreya.singh@gmail.com	Female	61	60	Delhi	1996-12-30
61	Amit Desai	amit.desai@gmail.com	Male	72	61	Jaipur	1995-01-11
62	Poonam Thakur	poonam.thakur@gmail.com	Female	83	62	Faridabad	1998-02-01
63	Tarun Verma	tarun.verma@gmail.com	Male	94	63	Mumbai	1999-03-15
64	Ritika Agarwal	ritika.agarwal@gmail.com	Female	5	64	Lucknow	1997-04-20
65	Rajesh Singh	rajesh.singh@gmail.com	Male	16	65	Raipur	1999-05-30
66	Suman Saini	suman.saini@gmail.com	Female	27	66	Bhopal	2001-06-15
88	Sandeep Verma	sandeep.verma@gmail.com	Male	69	88	Surat	1996-04-10
1	Aarav Sharma	aarav.sharma@gmail.com	Male	12	1	Delhi	1998-01-15
2	Ananya Gupta	ananya.gupta@gmail.com	Female	23	2	Mumbai	1999-02-25
3	Vihaan Kumar	vihaan.kumar@gmail.com	Male	34	3	Bangalore	2000-03-05
4	Aanya Verma	aanya.verma@gmail.com	Female	45	4	Chennai	1997-04-10
5	Arjun Reddy	arjun.reddy@gmail.com	Male	56	5	Hyderabad	2001-05-22
6	Pooja Singh	pooja.singh@gmail.com	Female	67	6	Kolkata	1995-06-30
7	Kabir Khan	kabir.khan@gmail.com	Male	78	7	Ahmedabad	1998-07-15
9	Rohan Patel	rohan.patel@gmail.com	Male	92	9	Jaipur	2000-09-09
10	Meera Nair	meera.nair@gmail.com	Female	11	10	Pune	1996-10-01
11	Sai Kumar	sai.kumar@gmail.com	Male	22	11	Coimbatore	1994-11-11
12	Nisha Yadav	nisha.yadav@gmail.com	Female	33	12	Lucknow	1998-12-21
13	Ishaan Joshi	ishaan.joshi@gmail.com	Male	44	13	Kochi	2001-01-03
14	Sneha Desai	sneha.desai@gmail.com	Female	55	14	Visakhapatnam	1997-02-17
15	Akash Bansal	akash.bansal@gmail.com	Male	66	15	Nagpur	2000-03-27
67	Nikhil Yadav	nikhil.yadav@gmail.com	Male	38	67	Indore	1995-07-01
68	Kajal Sharma	kajal.sharma@gmail.com	Female	49	68	Pune	1996-08-20
69	Apoorva Kaur	apoorva.kaur@gmail.com	Female	60	69	Nagpur	1998-09-11
70	Gaurav Yadav	gaurav.yadav@gmail.com	Male	71	70	Delhi	2000-10-12
71	Shivani Sharma	shivani.sharma@gmail.com	Female	82	71	Chennai	1996-11-15
72	Akhil Reddy	akhil.reddy@gmail.com	Male	93	72	Kolkata	1998-12-01
73	Naina Gupta	naina.gupta@gmail.com	Female	4	73	Bangalore	1995-01-21
74	Rishab Singh	rishab.singh@gmail.com	Male	15	74	Hyderabad	1999-02-18
75	Anjali Yadav	anjali.yadav@gmail.com	Female	26	75	Ahmedabad	1996-03-10
76	Harish Rao	harish.rao@gmail.com	Male	37	76	Raipur	1997-04-05
77	Diksha Mehta	diksha.mehta@gmail.com	Female	48	77	Faridabad	1998-05-15
78	Rahul Sharma	rahul.sharma@gmail.com	Male	59	78	Bhopal	1995-06-20
79	Parul Yadav	parul.yadav@gmail.com	Female	70	79	Coimbatore	1999-07-15
80	Ravindra Singh	ravindra.singh@gmail.com	Male	81	80	Chennai	1996-08-01
81	Vishakha Patel	vishakha.patel@gmail.com	Female	92	81	Delhi	1998-09-25
82	Himanshu Joshi	himanshu.joshi@gmail.com	Male	3	82	Indore	1995-10-11
83	Shweta Mehta	shweta.mehta@gmail.com	Female	14	83	Lucknow	1996-11-30
84	Dev Yadav	dev.yadav@gmail.com	Male	25	84	Jaipur	1999-12-05
85	Aditi Singh	aditi.singh@gmail.com	Female	36	85	Pune	1995-01-15
86	Raj Kumar	raj.kumar@gmail.com	Male	47	86	Nashik	1999-02-20
87	Nisha Kaur	nisha.kaur@gmail.com	Female	58	87	Ahmedabad	2000-03-30
89	Kavya Agarwal	kavya.agarwal@gmail.com	Female	70	89	Coimbatore	1998-05-11
90	Mohit Iyer	mohit.iyer@gmail.com	Male	71	90	Delhi	1999-06-12
91	Vani Sharma	vani.sharma@gmail.com	Female	72	91	Mumbai	1996-07-15
92	Nitin Singh	nitin.singh@gmail.com	Male	73	92	Bangalore	1998-08-16
93	Meenal Patel	meenal.patel@gmail.com	Female	74	93	Chennai	1999-09-17
94	Rajeev Kumar	rajeeve.kumar@gmail.com	Male	75	94	Hyderabad	1996-10-18
95	Gurpreet Singh	gurpreet.singh@gmail.com	Male	76	95	Kolkata	1995-11-19
96	Rohit Yadav	rohit.yadav@gmail.com	Male	77	96	Pune	1998-12-20
97	Bhumika Jain	bhumika.jain@gmail.com	Female	78	97	Ahmedabad	1996-01-21
98	Sakshi Singh	sakshi.singh@gmail.com	Female	79	98	Coimbatore	1999-02-22
99	Harish Gupta	harish.gupta@gmail.com	Male	80	99	Delhi	1995-03-23
100	Priyanka Reddy	priyanka.reddy@gmail.com	Female	81	100	Jaipur	1998-04-24
\.


--
-- TOC entry 5007 (class 0 OID 17981)
-- Dependencies: 240
-- Data for Name: youngster_phone; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.youngster_phone (youngster_id, phone_no) FROM stdin;
1	9876543210
1	9123456789
2	9876543211
3	9876543212
3	9123456790
4	9876543213
5	9876543214
6	9876543215
7	9876543216
8	9876543217
9	9876543218
10	9876543219
11	9876543220
12	9876543221
13	9876543222
14	9876543223
15	9876543224
16	9876543225
17	9876543226
18	9876543227
19	9876543228
20	9876543229
21	9876543230
22	9876543231
23	9876543232
24	9876543233
25	9876543234
26	9876543235
27	9876543236
28	9876543237
29	9876543238
30	9876543239
31	9876543240
32	9876543241
33	9876543242
34	9876543243
35	9876543244
36	9876543245
37	9876543246
38	9876543247
39	9876543248
40	9876543249
41	9876543250
42	9876543251
43	9876543252
44	9876543253
45	9876543254
46	9876543255
47	9876543256
48	9876543257
49	9876543258
50	9876543259
51	9876543260
52	9876543261
53	9876543262
54	9876543263
55	9876543264
56	9876543265
57	9876543266
58	9876543267
59	9876543268
60	9876543269
61	9876543270
62	9876543271
63	9876543272
64	9876543273
65	9876543274
66	9876543275
67	9876543276
68	9876543277
69	9876543278
70	9876543279
71	9876543280
72	9876543281
73	9876543282
74	9876543283
75	9876543284
76	9876543285
77	9876543286
78	9876543287
79	9876543288
80	9876543289
81	9876543290
82	9876543291
83	9876543292
84	9876543293
85	9876543294
86	9876543295
87	9876543296
88	9876543297
89	9876543298
90	9876543299
91	9876543300
92	9876543301
93	9876543302
94	9876543303
95	9876543304
96	9876543305
97	9876543306
98	9876543307
99	9876543308
100	9876543309
\.


--
-- TOC entry 5024 (class 0 OID 0)
-- Dependencies: 218
-- Name: city_city_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.city_city_id_seq', 115, true);


--
-- TOC entry 5025 (class 0 OID 0)
-- Dependencies: 233
-- Name: education_education_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.education_education_id_seq', 2, true);


--
-- TOC entry 5026 (class 0 OID 0)
-- Dependencies: 222
-- Name: employer_employer_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employer_employer_id_seq', 5, true);


--
-- TOC entry 5027 (class 0 OID 0)
-- Dependencies: 231
-- Name: employment_job_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.employment_job_id_seq', 121, true);


--
-- TOC entry 5028 (class 0 OID 0)
-- Dependencies: 227
-- Name: government_policy_policy_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.government_policy_policy_id_seq', 1, false);


--
-- TOC entry 5029 (class 0 OID 0)
-- Dependencies: 224
-- Name: health_facility_facility_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.health_facility_facility_id_seq', 1, false);


--
-- TOC entry 5030 (class 0 OID 0)
-- Dependencies: 220
-- Name: institute_institution_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.institute_institution_id_seq', 112, true);


--
-- TOC entry 5031 (class 0 OID 0)
-- Dependencies: 235
-- Name: migration_event_migration_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migration_event_migration_id_seq', 250, true);


--
-- TOC entry 5032 (class 0 OID 0)
-- Dependencies: 237
-- Name: opportunities_opportunity_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.opportunities_opportunity_id_seq', 162, true);


--
-- TOC entry 5033 (class 0 OID 0)
-- Dependencies: 216
-- Name: state_state_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.state_state_id_seq', 36, true);


--
-- TOC entry 5034 (class 0 OID 0)
-- Dependencies: 229
-- Name: youngster_youngster_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.youngster_youngster_id_seq', 120, true);


--
-- TOC entry 4795 (class 2606 OID 17769)
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (city_id);


--
-- TOC entry 4803 (class 2606 OID 17808)
-- Name: climate climate_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.climate
    ADD CONSTRAINT climate_pkey PRIMARY KEY (city_id, policy_id);


--
-- TOC entry 4813 (class 2606 OID 17875)
-- Name: education education_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_pkey PRIMARY KEY (education_id);


--
-- TOC entry 4799 (class 2606 OID 17794)
-- Name: employer employer_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employer
    ADD CONSTRAINT employer_pkey PRIMARY KEY (employer_id);


--
-- TOC entry 4811 (class 2606 OID 17861)
-- Name: employment employment_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.employment
    ADD CONSTRAINT employment_pkey PRIMARY KEY (job_id);


--
-- TOC entry 4819 (class 2606 OID 17925)
-- Name: enrolled enrolled_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrolled
    ADD CONSTRAINT enrolled_pkey PRIMARY KEY (youngster_id, institute_id);


--
-- TOC entry 4805 (class 2606 OID 17820)
-- Name: government_policy government_policy_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.government_policy
    ADD CONSTRAINT government_policy_pkey PRIMARY KEY (policy_id);


--
-- TOC entry 4801 (class 2606 OID 17802)
-- Name: health_facility health_facility_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.health_facility
    ADD CONSTRAINT health_facility_pkey PRIMARY KEY (facility_id);


--
-- TOC entry 4797 (class 2606 OID 17785)
-- Name: institute institute_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.institute
    ADD CONSTRAINT institute_pkey PRIMARY KEY (institution_id);


--
-- TOC entry 4815 (class 2606 OID 17899)
-- Name: migration_event migration_event_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_event
    ADD CONSTRAINT migration_event_pkey PRIMARY KEY (migration_id);


--
-- TOC entry 4817 (class 2606 OID 17913)
-- Name: opportunities opportunities_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_pkey PRIMARY KEY (opportunity_id);


--
-- TOC entry 4791 (class 2606 OID 17760)
-- Name: state state_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.state
    ADD CONSTRAINT state_pkey PRIMARY KEY (state_id);


--
-- TOC entry 4793 (class 2606 OID 17762)
-- Name: state state_state_name_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.state
    ADD CONSTRAINT state_state_name_key UNIQUE (state_name);


--
-- TOC entry 4807 (class 2606 OID 17851)
-- Name: youngster youngster_email_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster
    ADD CONSTRAINT youngster_email_key UNIQUE (email);


--
-- TOC entry 4821 (class 2606 OID 17985)
-- Name: youngster_phone youngster_phone_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster_phone
    ADD CONSTRAINT youngster_phone_pkey PRIMARY KEY (youngster_id, phone_no);


--
-- TOC entry 4809 (class 2606 OID 17849)
-- Name: youngster youngster_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster
    ADD CONSTRAINT youngster_pkey PRIMARY KEY (youngster_id);


--
-- TOC entry 4836 (class 2620 OID 18005)
-- Name: youngster auto_increment_ids; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER auto_increment_ids BEFORE INSERT ON public.youngster FOR EACH ROW EXECUTE FUNCTION public.increment_education_employment();


--
-- TOC entry 4822 (class 2606 OID 17770)
-- Name: city city_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.state(state_id) ON DELETE CASCADE;


--
-- TOC entry 4823 (class 2606 OID 17809)
-- Name: climate climate_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.climate
    ADD CONSTRAINT climate_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 4827 (class 2606 OID 17886)
-- Name: education education_city_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_city_id_fkey FOREIGN KEY (city_id) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 4828 (class 2606 OID 17881)
-- Name: education education_institute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.education
    ADD CONSTRAINT education_institute_id_fkey FOREIGN KEY (institute_id) REFERENCES public.institute(institution_id) ON DELETE CASCADE;


--
-- TOC entry 4833 (class 2606 OID 17931)
-- Name: enrolled enrolled_institute_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrolled
    ADD CONSTRAINT enrolled_institute_id_fkey FOREIGN KEY (institute_id) REFERENCES public.institute(institution_id) ON DELETE CASCADE;


--
-- TOC entry 4834 (class 2606 OID 17926)
-- Name: enrolled enrolled_youngster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.enrolled
    ADD CONSTRAINT enrolled_youngster_id_fkey FOREIGN KEY (youngster_id) REFERENCES public.youngster(youngster_id) ON DELETE CASCADE;


--
-- TOC entry 4825 (class 2606 OID 17946)
-- Name: youngster fk_education; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster
    ADD CONSTRAINT fk_education FOREIGN KEY (education_id) REFERENCES public.education(education_id) ON DELETE SET NULL;


--
-- TOC entry 4826 (class 2606 OID 17951)
-- Name: youngster fk_employment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster
    ADD CONSTRAINT fk_employment FOREIGN KEY (employment_id) REFERENCES public.employment(job_id) ON DELETE SET NULL;


--
-- TOC entry 4829 (class 2606 OID 17961)
-- Name: migration_event fk_from_region; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_event
    ADD CONSTRAINT fk_from_region FOREIGN KEY (from_region) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 4830 (class 2606 OID 17966)
-- Name: migration_event fk_to_region; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_event
    ADD CONSTRAINT fk_to_region FOREIGN KEY (to_region) REFERENCES public.city(city_id) ON DELETE CASCADE;


--
-- TOC entry 4824 (class 2606 OID 17956)
-- Name: government_policy government_policy_state_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.government_policy
    ADD CONSTRAINT government_policy_state_id_fkey FOREIGN KEY (state_id) REFERENCES public.state(state_id) ON DELETE CASCADE;


--
-- TOC entry 4831 (class 2606 OID 17900)
-- Name: migration_event migration_event_youngster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migration_event
    ADD CONSTRAINT migration_event_youngster_id_fkey FOREIGN KEY (youngster_id) REFERENCES public.youngster(youngster_id) ON DELETE CASCADE;


--
-- TOC entry 4832 (class 2606 OID 17914)
-- Name: opportunities opportunities_employer_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.opportunities
    ADD CONSTRAINT opportunities_employer_id_fkey FOREIGN KEY (employer_id) REFERENCES public.employer(employer_id) ON DELETE CASCADE;


--
-- TOC entry 4835 (class 2606 OID 17986)
-- Name: youngster_phone youngster_phone_youngster_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.youngster_phone
    ADD CONSTRAINT youngster_phone_youngster_id_fkey FOREIGN KEY (youngster_id) REFERENCES public.youngster(youngster_id) ON DELETE CASCADE;


-- Completed on 2024-12-26 18:13:23

--
-- PostgreSQL database dump complete
--

