<script>
  import nuiMessage from './utils/nui.js';
  import { ref } from 'vue';

  import item from './components/item.vue';
  import category from './components/category.vue';
  
  export default {
    data() {
        return {
          display: false,
          shopName: "Shop",
          cart: {},
          cartTotal: 0,
          playerBank: 0,
          playerCash: 0,
          shopData: {},
          categories: [],
          items: {},
          shopItems: {},
        }
    },
    setup() {
      const itemComponents = ref({});
      return { itemComponents }
    },
    components: {
      item,
      category,
    },
    methods: {

      findCategories: function() {
        this.categories.push('ALL');

        for (const item of Object.entries(this.items)) {
          if (!this.categories.includes(item[1].category)) {
            this.categories.push(item[1].category);
          }
        }

      },

      filterCategory: function(category) {
        if (category === "ALL") {
          this.items = this.shopItems;
        } else {
          this.items = this.shopItems;
          let temp = []
          for (const item of Object.entries(this.items)) {
            if (item[1].category == category) {
              temp.push(item[1]);
            }
          }
          this.items = temp;
        }
      },

      // Update the cart total price based on items inside the cart.
      cartUpdatePrice: function() {
        this.cartTotal = 0;
        for (let item in this.cart) {
          this.cartTotal += this.items[item].price * this.cart[item];
        }
      },

      cartUpdateItem: function(name, quantity) {
        // Added quantity to cart. If quantity is 0, remove the item from the cart.
        if (quantity > 0) {
          this.cart[name] = quantity;
        } else {
          delete this.cart[name];
        }

        this.cartUpdatePrice();
      },

      resetCart: function() {
        this.cart = {};
		    this.categories = [];
        this.cartTotal = 0;

        for (let item in this.itemComponents) {
          this.itemComponents[item].quantity = 0;
        }
      },

      purchase: async function(account) {
        if (Object.keys(this.cart).length === 0) return;

        const result = await nuiMessage("purchase", { items: this.cart, account: account, key: this.shopData.key, locationId: this.shopData.locationId });
        if (result.success) {
          
          switch (account) {
            case 'bank':
              this.playerBank -= this.cartTotal;
              break;
            case 'cash':
              this.playerCash -= this.cartTotal;
              break;
          }

          this.resetCart();

          if (result.items) {
            this.items = result.items;
          }

        }
      }
    },
    unmounted() {
      window.removeEventListener("message", this.listener);
    },
    mounted() {

      this.listener = window.addEventListener("message", (event) => {
        switch (event.data.action) {
          case 'open':
            this.display = true;
            this.shopName = event.data.shopName;
            this.items = event.data.items;
            this.shopItems = event.data.items;
            this.shopData.key = event.data.key;
            this.shopData.locationId = event.data.locationId;
            this.playerBank = event.data.bank;
            this.playerCash = event.data.cash;
            this.findCategories();
            break;
          case 'close':
            this.display = false;
            this.resetCart();
            break;
        }
      });

      this.listener = window.addEventListener("keyup", (event) => {
        if (event.key == 'Escape') {
          nuiMessage("close")
        }
      });
    },
}
</script>

<template>
	  <transition name="slide-out-left">
		<div class="container" v-if="display">
			<div class="shop-container">
				<div class="shop-header">
					<h1>{{ this.shopName }}</h1>

					<div class="shop-monetary-container">
						<div class="shop-cart">
							<img src="/assets/basket.png">
							<p>$ <span>{{ this.cartTotal }}</span></p>
						</div>

						<div class="player-bank">
							<img src="/assets/safe.png">
							<p>$ <span>{{ this.playerBank }}</span></p>
						</div>

						<div class="player-cash">
							<img src="/assets/money.png">
							<p>$ <span>{{ this.playerCash }}</span></p>
						</div>
					</div>
				</div>

				<div class="wrapper">
					<div class="shop-items-container">
						<item v-for="(item, key, index) in this.items" :ref="el => itemComponents[index] = el" :name="key" :label="item.label" :price="item.price" :stock="item.stock" :image="item.image" />
					</div>
				</div>

			</div>
			
			<div class="shop-actions">

				<div class="shop-buttons">
					<div class="btn bank" @click="this.purchase('bank')">
						<img src="/assets/safe.png">
						<span class="tooltip bank">pay with bank</span>
					</div>

					<div class="btn cash" @click="this.purchase('cash')">
						<img src="/assets/money.png">
						<span class="tooltip cash">pay with cash</span>
					</div>

					<div class="btn cart" @click="this.resetCart()">
						<img src="/assets/basket.png">
						<span class="tooltip cart">empty basket</span>
					</div>
				</div>
				
				<div class="catergories-container">
					<category v-for="category in this.categories" :category="category" @click="this.filterCategory(category)" />
				</div>
			</div>
		</div>
	</transition>
</template>

<style>
    .container {
        position: absolute;
        height: 100%;
        width: 100%;
        display: flex;
        text-transform: capitalize;
        font-family: "Bebas Neue", sans-serif;
        font-weight: 400;
        font-style: normal;
    }

    .shop-buttons .tooltip {
        visibility: hidden;
        width: 120px;
        color: #fff;
        font-size: 14px;
        text-align: center;
        border-radius: 6px;
        padding: 5px 0;
        margin-left: 163px;
        position: absolute;
        z-index: 1;
        background-color: var(--dark2);
    }

    .shop-buttons .btn:hover .tooltip {
        visibility: visible;
    }

    .shop-actions {
        position: relative;
        display: flex;
        flex-direction: column;
        /* align-items: center; */
		justify-content: flex-start;
        height: auto;
		width: auto;
        /* margin: 5px; */
    }
	
    .catergories-container {
        display: flex;
        flex-direction: column;
        margin-top: 60px;
        gap: 10px;
    }

    .shop-actions div {
        border-radius: 8px;
        padding: 10px;
    }

    .shop-actions .btn img {
        height: 40px;
        width: auto;
    }

    .shop-actions .shop-buttons div:hover {
        cursor: pointer;
        background: rgb(253, 34, 130);
        background: radial-gradient(circle, rgba(253, 34, 130, 1) 0%, rgba(253, 34, 130, 0.347) 100%); 
    }

    .catergories-container div:hover {
        cursor: pointer;
        background: rgb(253, 34, 130);
        background: radial-gradient(circle, rgba(253, 34, 130, 1) 0%, rgba(253, 34, 130, 0.347) 100%); 
    }
    
    .shop-buttons {
        display: flex;
        flex-direction: column;
        gap: 10px;
    }
    
    .shop-buttons .btn {
      width: auto;
      display: flex;
      justify-content: center;
      background-color: var(--dark2);
    }

    .shop-container {
        position: relative;
        height: 100%;
        width: 550px;
        display: flex;
        flex-direction: column;
        background-color: #08090cee;
    }

    .shop-header {
        position: relative;
        height: 50px;
        width: 100%;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: flex-start;
        background-color: var(--dark);
    }

    .shop-header h1 {
        margin-left: 14px;
        font-size: 20px;
        color: var(--primary-color);
    }

    .shop-header h1 span {
        color: white;
    }

    .shop-monetary-container {
        position: absolute;
        right: 10px;
        height: 40%;
        width: auto;
        max-width: 380px;
        gap: 26px;
        padding: 8px;
        border-radius: 30px;
        display: flex;
        flex-direction: row;
        align-items: center;
        object-fit: contain;
        justify-content: center;
        background-color: var(--dark2);
    }

	.shop-monetary-container img {
		height: 20px;
		width: auto;
	}
	
    .shop-cart {
        position: relative;
        height: 100%;
        width: auto;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
    }

    .shop-cart p {
        margin-left: 5px;
        font-size: 14px;
        color: var(--primary-color);
    }

    .shop-cart p span {
        color: white;
    }

    .player-bank {
        position: relative;
        height: 100%;
        width: auto;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
    }

    .player-bank p {
        margin-left: 5px;
        font-size: 14px;
        color: var(--primary-color);
    }

    .player-bank p span {
        color: white;
    }

    .player-cash {
        position: relative;
        height: 100%;
        width: auto;
        display: flex;
        flex-direction: row;
        align-items: center;
        justify-content: center;
    }

    .player-cash p {
        margin-left: 5px;
        font-size: 14px;
        color: var(--primary-color);
    }

    .player-cash p span {
        color: white;
    }

    .shop-items-container {
        position: relative;
        /* height: 100%; */
        width: fit-content;
        margin: 20px;
        display: flex;
        flex-wrap: wrap;
        gap: 30px;
        flex-direction: row;
        justify-content: center;
    }

	.wrapper {
		width: 100%;
		height: auto;
		display: flex;
		flex-direction: row;
		justify-content: center;
		overflow-y: auto;
	}

	.slide-out-left-enter-active {
        animation: slide-out-left-in .5s;
    }

    .slide-out-left-leave-active {
        animation: slide-out-left-out .5s;
    }

    @keyframes slide-out-left-in {
        0% {
            opacity: 0;
            transform: translateX(-100%);
        }
        100% {
            opacity: 1;
            transform: translateX(0);
        }
    }

    @keyframes slide-out-left-out {
        0% {
            opacity: 1;
            transform: translateX(0);
        }
        100% {
            opacity: 0;
            transform: translateX(-100%);
        }
    }

	/* width */
	::-webkit-scrollbar {
        width: 6px; /* adjust the width of the scrollbar */
    }

    /* Track */
    ::-webkit-scrollbar-track {
        border-radius: 4px;
        background: #f1f1f1; /* color of the track */
    }

    /* Handle */
    ::-webkit-scrollbar-thumb {
		border-radius: 4px;
        background: var(--primary-color); /* color of the scrollbar handle */
    }

    /* Handle on hover */
    ::-webkit-scrollbar-thumb:hover {
        background: var(--accent-color); /* color of the scrollbar handle on hover */
    }
</style>