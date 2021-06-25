-- связь юзеров и документов 
CREATE TABLE "public"."user_doc_link" (
"user_id" int4 DEFAULT 0 NOT NULL,
"document_id" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "user_documents_pkey" PRIMARY KEY ("user_id", "document_id"),
CONSTRAINT "user_id" FOREIGN KEY ("users") REFERENCES status ("id"),
CONSTRAINT "document_id" FOREIGN KEY ("user_doc") REFERENCES status ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_doc_link" OWNER TO "troll";