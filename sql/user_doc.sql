--таблица
DROP TABLE IF EXISTS "public"."documents";
DROP SEQUENCE IF EXISTS "public".documents_id_seq; 

CREATE SEQUENCE "public".documents_id_seq;
-- ALTER SEQUENCE "documents_id_seq" RESTART WITH 1;

CREATE TABLE "public"."documents" (
    "id" int4 DEFAULT nextval('documents_id_seq'::regclass) NOT NULL,
    "new_name" varchar(255) COLLATE "default" NOT NULL,
    "old_name" varchar(255) COLLATE "default" NOT NULL,
    "extension" varchar(5) COLLATE "default" NOT NULL,
    "size" int4,
    "time_create" timestamptz(6) DEFAULT CURRENT_TIMESTAMP,
    "description" varchar(4096) COLLATE "default",
    CONSTRAINT "documents_pkey" PRIMARY KEY ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."documents" OWNER TO "troll";
ALTER TABLE "public"."documents" ADD CONSTRAINT name UNIQUE (name);


CREATE UNIQUE INDEX "documents_name_idx" ON "public"."documents" USING btree ("name");