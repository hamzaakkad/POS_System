-- MySQL Workbench Forward Engineering

SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema mydb
-- -----------------------------------------------------
-- -----------------------------------------------------
-- Schema pos_system
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema pos_system
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `pos_system` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `pos_system` ;

-- -----------------------------------------------------
-- Table `pos_system`.`categories`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pos_system`.`categories` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 24
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `pos_system`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pos_system`.`orders` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `total_price` DECIMAL(10,2) NOT NULL DEFAULT '0.00',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`))
ENGINE = InnoDB
AUTO_INCREMENT = 93
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `pos_system`.`product`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pos_system`.`product` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(255) NOT NULL,
  `category_id` INT NULL DEFAULT NULL,
  `price` DECIMAL(10,2) NOT NULL,
  `storage_quantity` INT NULL DEFAULT '0',
  `is_archived` TINYINT(1) NULL DEFAULT '0',
  `created_at` TIMESTAMP NULL DEFAULT CURRENT_TIMESTAMP,
  `image_url` VARCHAR(1024) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `idx_pagination` (`is_archived` ASC, `id` DESC) VISIBLE,
  INDEX `fk_category` (`category_id` ASC) VISIBLE,
  CONSTRAINT `fk_category`
    FOREIGN KEY (`category_id`)
    REFERENCES `pos_system`.`categories` (`id`)
    ON DELETE SET NULL)
ENGINE = InnoDB
AUTO_INCREMENT = 184
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `pos_system`.`ordered_item`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pos_system`.`ordered_item` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `order_id` INT NOT NULL,
  `product_id` INT NOT NULL,
  `quantity` INT NOT NULL,
  `unit_price` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`id`),
  INDEX `fk_items_order_id` (`order_id` ASC) VISIBLE,
  INDEX `fk_items_product_id` (`product_id` ASC) VISIBLE,
  CONSTRAINT `fk_items_order_id`
    FOREIGN KEY (`order_id`)
    REFERENCES `pos_system`.`orders` (`id`)
    ON DELETE CASCADE,
  CONSTRAINT `fk_items_product_id`
    FOREIGN KEY (`product_id`)
    REFERENCES `pos_system`.`product` (`id`)
    ON DELETE RESTRICT)
ENGINE = InnoDB
AUTO_INCREMENT = 97
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


-- -----------------------------------------------------
-- Table `pos_system`.`product_category_rel`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `pos_system`.`product_category_rel` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `product_id` INT NULL DEFAULT NULL,
  `category_id` INT NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `product_id` (`product_id` ASC) VISIBLE,
  INDEX `category_id` (`category_id` ASC) VISIBLE,
  CONSTRAINT `product_category_rel_ibfk_1`
    FOREIGN KEY (`product_id`)
    REFERENCES `pos_system`.`product` (`id`),
  CONSTRAINT `product_category_rel_ibfk_2`
    FOREIGN KEY (`category_id`)
    REFERENCES `pos_system`.`categories` (`id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb4
COLLATE = utf8mb4_0900_ai_ci;


SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;
