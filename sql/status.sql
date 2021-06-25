--таблица
DROP TABLE IF EXISTS "public"."status";
DROP SEQUENCE IF EXISTS "public".status_id_seq; 

CREATE SEQUENCE "public".status_id_seq;
-- ALTER SEQUENCE "status_id_seq" RESTART WITH 1;

CREATE TABLE "public"."status" (
    "id" int4 DEFAULT nextval('status_id_seq'::regclass) NOT NULL,
    "name" varchar(255) COLLATE "default" NOT NULL,
    "status" int2 DEFAULT 1 NOT NULL,
    CONSTRAINT "status_pkey" PRIMARY KEY ("status")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."status" OWNER TO "troll";
ALTER TABLE "public"."status" ADD CONSTRAINT name UNIQUE (name);