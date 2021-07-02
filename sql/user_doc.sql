--таблица
DROP TABLE IF EXISTS "public"."user_doc";
DROP SEQUENCE IF EXISTS "public".doc_id_seq; 

CREATE SEQUENCE "public".doc_id_seq;

CREATE TABLE "public"."user_doc" (
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

ALTER TABLE "public"."user_doc" OWNER TO "troll";

CREATE UNIQUE INDEX "documents_name_idx" ON "public"."user_doc" USING btree ("id");