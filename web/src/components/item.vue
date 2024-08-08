<script>

    export default {
        name: 'item',
        props: {
            name: String,
            label: String,
            image: String,
            price: Number,
            stock: Number,
        },
        data() {
            return {
                quantity: 0
            }
        },
        methods: {
            addItem: function() {
                this.quantity += 1;
                if (this.quantity > this.stock) {
                    this.quantity = this.stock;
                }
                this.$root.cartUpdateItem(this.name, this.quantity);
            },
            removeItem: function() {

                if (this.quantity > 0) {
                    this.quantity -= 1;
                }
                
                this.$root.cartUpdateItem(this.name, this.quantity);
            },
            changeHandler: function() {
                this.$root.cartUpdateItem(this.name, this.quantity);
            },
            max: function() {
                this.quantity = this.stock;
                this.$root.cartUpdateItem(this.name, this.stock);
            },
        },
    };
</script>

<template>
    <div class="shop-item" v-on:click.left = "this.addItem()" v-on:click.right="this.removeItem()" v-on:click.middle="this.max()">
        <div class="shop-item-price">
            <img src="/assets/money.png" alt="money" />
            <p class="item-price">$ <span>{{ this.price }}</span></p>
        </div>
        <div class="shop-item-image-container">
            <img :src="this.image" onerror="this.onerror=null; this.src='https://cfx-nui-ox_inventory/web/images/missing.png'" alt="item" />
        </div>
        <p>{{ this.label }}</p>

        <div class="shop-item-info">
            <div class="item-stock">
                <p>{{ this.stock }}</p>
            </div>

            <div class="item-purchase">
                <p>{{ quantity }}</p>
            </div>
        </div>
    </div>
</template>

<style>
    .shop-item {
        position: relative;
        height: fit-content;
        width: 120px;
        padding: 5px;
        /* margin: auto; */
        border-radius: 8px;
        display: flex;
        flex-direction: column;
        align-items: center;
        justify-content: center;
        background-color: var(--dark);
    }

    .shop-item:hover {
        background: rgb(253, 34, 130);
        background: radial-gradient(circle, rgba(253, 34, 130, 1) 0%, rgba(253, 34, 130, 0.347) 100%); 
    }

    .shop-item-price {
        position: absolute;
        top: -12px;
        right: -20px;
        height: auto;
        width: auto;
        padding: 3px;
        border-radius: 8px;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
        z-index: 1;
        background-color: var(--dark2);
    }


    .shop-item-price img {
        height: 20px;
        width: auto;
    }

    .shop-item-price p {
        font-size: 12px;
        color: var(--primary-color);
    }
    
    .shop-item-price .item-price {
        color: var(--accent);
    }

    .shop-item-image-container {
        position: relative;
        height: auto;
        /* max-height: a; */
        width: auto;
        display: flex;
        align-items: center;
        justify-content: center;
        object-fit: contain;
    }

    .shop-item-image-container img {
        height: 90px;
        width: 90px;
        object-fit: contain;

    }

    .shop-item p {
        margin: 5px;
        font-size: 14px;
        color: var(--primary-color);
    }

    .shop-item-info {
        position: relative;
        height: 26px;
        width: 100%;
        gap: 5px;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: space-between;
    }

    .shop-item-info div {
        border-radius: 50px;
        background-color: var(--accent);
    }

    .item-stock {
        position: relative;
        height: 100%;
        width: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        color: var(--primary-color);
    }

    .item-purchase {
        position: relative;
        height: 100%;
        width: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 14px;
        color: var(--primary-color);
    }

    .item-purchase p {
        padding: 5px;
        border-radius: 8px;
        color: var(--accent);
    }
</style>