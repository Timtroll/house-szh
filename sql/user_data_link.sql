-- связь юзеров и данных 
CREATE TABLE "public"."user_data_link" (
"user_id" int4 DEFAULT 0 NOT NULL,
"data_id" int4 DEFAULT 0 NOT NULL,
CONSTRAINT "user_data_pkey" PRIMARY KEY ("user_id", "data_id"),
CONSTRAINT "user_id" FOREIGN KEY ("users") REFERENCES status ("id"),
CONSTRAINT "data_id" FOREIGN KEY ("user_data") REFERENCES status ("id")
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_data_link" OWNER TO "troll";