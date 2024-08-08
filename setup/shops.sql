CREATE TABLE `shops` (
	`id` INT(11) NOT NULL,
	`name` VARCHAR(50) NOT NULL DEFAULT '' COLLATE 'utf8mb4_general_ci',
	`items` TEXT NULL DEFAULT NULL COLLATE 'utf8mb4_general_ci'
)
COLLATE='utf8mb3_general_ci'
ENGINE=InnoDB
;
