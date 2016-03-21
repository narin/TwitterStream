CREATE SCHEMA `tweetstream` DEFAULT CHARACTER SET utf8 ;

SET NAMES utf8mb4;
ALTER DATABASE tweetstream CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci;

CREATE TABLE `tweetstream`.`user` (
  `id` bigint(40) NOT NULL,
  `username` VARCHAR(250) NOT NULL,
  `name` VARCHAR(250) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `profile_img_url` VARCHAR(2000) NULL,
  `record_creation_datetime` DATETIME NOT NULL,
  PRIMARY KEY (`id`));

CREATE TABLE `tweetstream`.`tweet` (
  `id` bigint(40) NOT NULL,
  `text` VARCHAR(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `record_creation_datetime` DATETIME NULL,
  `user_id` bigint(40) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `user_id_idx` (`user_id` ASC),
  CONSTRAINT `fk_tweet_user_user_id_id`
    FOREIGN KEY (`user_id`)
    REFERENCES `tweetstream`.`user` (`id`)
    ON DELETE NO ACTION
    ON UPDATE RESTRICT
  );

CREATE TABLE `tweetstream`.`url` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `url` VARCHAR(500) NOT NULL,
  `resolved_url` VARCHAR(2000) NULL,
  `record_creation_datetime` DATETIME NULL,
  `tweet_id` bigint(40) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `tweet_id_idx` (`tweet_id` ASC),
  CONSTRAINT `fk_url_tweet_tweet_id_id`
    FOREIGN KEY (`tweet_id`)
    REFERENCES `tweetstream`.`tweet` (`id`)
    ON DELETE NO ACTION
    ON UPDATE RESTRICT);
