-- связь юзеров и документов 
CREATE TABLE "public"."user_documents" (
"user_id" int4 DEFAULT 0 NOT NULL,
"document_id" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "user_documents_pkey" PRIMARY KEY ("user_id", "document_id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_documents" OWNER TO "troll";