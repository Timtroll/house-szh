-- связь юзеров и данных 
CREATE TABLE "public"."user_data" (
"user_id" int4 DEFAULT 0 NOT NULL,
"data_id" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "user_data_pkey" PRIMARY KEY ("user_id", "data_id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_data" OWNER TO "troll";