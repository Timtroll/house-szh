--таблица
DROP TABLE IF EXISTS "public"."user_data";
DROP SEQUENCE IF EXISTS "public".data_id_seq; 

CREATE SEQUENCE "public".data_id_seq;

CREATE TABLE "public"."user_data" (
    "id" int4 DEFAULT nextval('data_id_seq'::regclass) NOT NULL,
    "name" varchar(255) COLLATE "default" NOT NULL,
    "surname" varchar(255) COLLATE "default" NOT NULL,
    "patronymic" varchar(255) COLLATE "default" NOT NULL,
    "phone" varchar(16) COLLATE "default" DEFAULT NULL::character varying,
    CONSTRAINT "data_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_data" OWNER TO "troll";

CREATE UNIQUE INDEX "data_id_idx" ON "public"."user_data" USING btree ("id");