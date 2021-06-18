--таблица
DROP TABLE IF EXISTS "public"."documents";
DROP SEQUENCE IF EXISTS "public".documents_id_seq; 

CREATE SEQUENCE "public".documents_id_seq;
-- ALTER SEQUENCE "documents_id_seq" RESTART WITH 1;

CREATE TABLE "public"."documents" (
    "id" int4 DEFAULT nextval('documents_id_seq'::regclass) NOT NULL,
    "name" varchar(255) COLLATE "default" NOT NULL,
    "status" int2 DEFAULT 1 NOT NULL,
    CONSTRAINT "documents_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."documents" OWNER TO "troll";
ALTER TABLE "public"."documents" ADD CONSTRAINT name UNIQUE (name);


CREATE UNIQUE INDEX "documents_name_idx" ON "public"."documents" USING btree ("name");