--таблица
DROP TABLE IF EXISTS "public"."user_data";
DROP SEQUENCE IF EXISTS "public".data_id_seq; 

CREATE SEQUENCE "public".data_id_seq;
-- ALTER SEQUENCE "data_id_seq" RESTART WITH 1;

CREATE TABLE "public"."user_data" (
    "id" int4 DEFAULT nextval('users_id_seq'::regclass) NOT NULL,
    "login" varchar(16) COLLATE "default" DEFAULT NULL::character varying,
    "email" varchar(255) COLLATE "default" DEFAULT NULL::character varying,
    "phone" varchar(16) COLLATE "default" DEFAULT NULL::character varying,
    "password" varchar(64) COLLATE "default" DEFAULT NULL::character varying,
    CONSTRAINT "data_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_data" OWNER TO "troll";
ALTER TABLE "public"."user_data" ADD CONSTRAINT name UNIQUE (id);


CREATE UNIQUE INDEX "data_id_idx" ON "public"."user_data" USING btree ("id");