-- связь юзеров и групп 
CREATE TABLE "public"."user_links" (
"first_id" int4 DEFAULT 0 NOT NULL,
"first_type" varchar(255) COLLATE "default" NOT NULL,
"second_id" int4 DEFAULT 0 NOT NULL,
"second_type" varchar(255) COLLATE "default" NOT NULL,
)
WITH (OIDS=FALSE);

ALTER TABLE "public"."user_links" OWNER TO "troll";